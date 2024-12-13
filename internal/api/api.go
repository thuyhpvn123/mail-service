package api

import (
	"github.com/gin-gonic/gin"
	"errors"
	"net/http"
)
var(
	ErrNotFound = errors.New(http.StatusText(http.StatusNotFound))
)
func ResponseWithErrorAndMessage(status int, err error, c *gin.Context) {
	c.Header("Content-Type", "application/json")
	if err != nil {
		c.AbortWithStatusJSON(status, map[string]interface{}{
			"error": err.Error(),
		})
		return
	}
	c.AbortWithStatusJSON(status, nil)
}

func ResponseWithStatusAndData(status int, data interface{}, c *gin.Context) {
	c.Header("Content-Type", "application/json")
	c.JSON(status, data)
}

// Simplified function
func ResponseWithError(err error, c *gin.Context) {
	c.Header("Content-Type", "application/json")
	
	if err != nil {
		// Check for 404 error
		if errors.Is(err, ErrNotFound) {
			c.AbortWithStatus(http.StatusNotFound)
			return
		}
		// For other errors, return 500 with error message
		c.AbortWithStatusJSON(http.StatusInternalServerError, map[string]interface{}{
			"error": err.Error(),
		})
		return
	}

	// // If no error, respond with 200 OK
	// c.AbortWithStatusJSON(http.StatusOK, map[string]interface{}{
	// 	"message": "success",
	// })
}