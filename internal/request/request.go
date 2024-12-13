package request

type PushMailRequest struct {
	Sender string `json:"sender" validate:"required"` 
	Subject    string `json:"subject" validate:"required"` 
	From       string `json:"from" validate:"required"` 
	FromHeader string `json:"from-header" validate:"required"` 
	ReplyTo    string `json:"reply-to" validate:"required"` 
	MessageID  string `json:"message-id" validate:"required"` 
	Body       string `json:"body" validate:"required"` 
	Html       string `json:"html" validate:"required"` 
	Files      []File `json:"files"` 
	CreatedAt  uint64 `json:"create-at" validate:"required"` 
	Receiver   string `json:"receiver" validate:"required"`  //fullname in ens : dong.mtd
}
type File struct {
	ContentDisposition string `json:"content-disposition"`
	ContentID          string `json:"content-id"`
	ContentType        string `json:"content-type"`
}
