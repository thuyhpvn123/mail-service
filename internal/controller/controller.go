package controller

import (
	"errors"
	"fmt"
	"io/ioutil"
	"math/big"
	"net/http"
	"net/url"
	"strings"

	// "github.com/holiman/uint256"
	"github.com/ethereum/go-ethereum/common"
	"github.com/gin-gonic/gin"
	"github.com/meta-node-blockchain/mail-service/internal/api"
	"github.com/meta-node-blockchain/mail-service/internal/request"
	"github.com/meta-node-blockchain/mail-service/internal/services"
)

type Controller interface {
	PushEmail(c *gin.Context)
}
type controller struct {
	servs       services.SendTransactionService
	ownerUrl    string
}

func NewController(
	servs services.SendTransactionService,
	ownerUrl    string,
) Controller {
	return &controller{
		servs,
		ownerUrl,
	}
}

func (h *controller) PushEmail(c *gin.Context) {
	var queryParam request.PushMailRequest
	if err := c.ShouldBindJSON(&queryParam); err != nil {
		// Handle error
		api.ResponseWithErrorAndMessage(http.StatusBadRequest, err, c)
		return
	}
	receiver := queryParam.Receiver
	//
	// Construct the URL with the domain name
	baseURL := h.ownerUrl + receiver
	apiURL, err := url.Parse(baseURL)
	if err != nil {
		api.ResponseWithError(err, c)
		return
	}

	// Create the HTTP request
	resp, err := http.Get(apiURL.String())
	if err != nil {
		api.ResponseWithError(err, c)
		return
	}
	defer resp.Body.Close()
	// Check the response status code
	if resp.StatusCode != http.StatusOK {
		// body, _ := io.ReadAll(resp.Body)
		errMessage := fmt.Sprintf("Received non-OK HTTP status: %s.", resp.Status)
		api.ResponseWithError(errors.New(errMessage), c)
		return
	}

	// Read the response body
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		api.ResponseWithError(err, c)
		return
	}
	// Convert the body to string
	bodyStr := string(body)
	// Trim any whitespace (including \n) from bodyStr
	bodyStr = strings.TrimSpace(bodyStr)
	fmt.Println("bodyStr:",bodyStr)
	//
	add := "0x"+bodyStr
	mailStorageAdd, err := h.servs.GetEmailStorage(add)
	if err != nil {
		api.ResponseWithError(err, c)
		return
	}
	fmt.Println("mailStorageAdd :",mailStorageAdd)
	fmt.Printf("%T",mailStorageAdd)
	if mailStorageAdd.(common.Address) == common.HexToAddress("0x0000000000000000000000000000000000000000") {
		message := gin.H{
			"message": "no address mail contract found",
			"data":    false,
		}
		api.ResponseWithStatusAndData(http.StatusOK, message, c)
		return
	}
	result, err := h.servs.CreateEmail(
		mailStorageAdd.(common.Address),
		queryParam.Sender, 
		queryParam.Subject, 
		queryParam.FromHeader, 
		queryParam.ReplyTo,
		queryParam.MessageID,
		queryParam.Body,
		queryParam.Html,
		queryParam.Files,
		queryParam.CreatedAt,
	)
	if err != nil {
		api.ResponseWithError(err, c)
		return
	}
	zero := big.NewInt(0)
	value, ok := result.(*big.Int)
	if !ok {
		fmt.Println("Assertion failed")
		return
	}
	if value.Cmp(zero)>0 {
		message := gin.H{
			"message": "successful request",
			"data":    result,
		}
		api.ResponseWithStatusAndData(http.StatusOK, message, c)
	} else {
		message := gin.H{
			"message": "fail request",
			"data":    result,
		}
		api.ResponseWithStatusAndData(http.StatusOK, message, c)
	}

}

