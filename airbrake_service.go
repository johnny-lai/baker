package bedrock

import (
	"errors"
	"fmt"
	"github.com/airbrake/gobrake"
	"github.com/gin-gonic/gin"
	"net/http"
)

type AirbrakeConfig struct {
	ProjectID  int64
	ProjectKey string
}

type AirbrakeService struct {
	Config   AirbrakeConfig
	Notifier *gobrake.Notifier
}

func (s *AirbrakeService) Configure(app *Application) error {
	return app.BindConfigAt(&s.Config, "airbrake")
}

func (s *AirbrakeService) Build(app *Application) error {
	s.Notifier = gobrake.NewNotifier(s.Config.ProjectID, s.Config.ProjectKey)

	app.Engine.Use(s.RecoveryHandler(app))
	app.OnException = s.ExceptionHandler(app)
	return nil
}

func (s *AirbrakeService) PanicHandler(app *Application) func(*gin.Context) {
	return func(c *gin.Context) {
		panic("Panicking")
	}
}

func (s *AirbrakeService) RecoveryHandler(app *Application) func(*gin.Context) {
	w := gin.DefaultWriter
	return func(c *gin.Context) {
		defer func() {
			if rval := recover(); rval != nil {
				rvalStr := fmt.Sprint(rval)
				w.Write([]byte(fmt.Sprintf("recovering from:%s at:%s", rvalStr, c.Request.URL)))
				err := errors.New(rvalStr)
				app.OnException(c, err)
				c.AbortWithError(http.StatusInternalServerError, err)
			}
			defer s.Notifier.Flush()
		}()
		c.Next()
	}
}

func (s *AirbrakeService) ExceptionHandler(app *Application) func(*gin.Context, error) {
	return func(c *gin.Context, err error) {
		app.LogException(c, err)
		s.Notifier.Notify(err, c.Request)
		defer s.Notifier.Flush()
	}
}
