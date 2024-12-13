// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
struct File {
    string contentDisposition;
    string contentID;
    string contentType;
}
struct Email {
    uint256 id;
    string subject;
    string from;
    string fromHeader;
    string replyTo;
    string messageID;
    string body;
    string html;
    uint256 createdAt;
    File[] files;
}
struct UserReceiverEmail {
    uint256 emailID;
    address userAddress;
    bool status;
}
interface IEmailStorage{
    function setService(address _service)external;
    function setStorageOwner(address _storageOwner)external;
    function createEmail(
        string memory sender,
        string memory subject,
        string memory fromHeader,
        string memory replyTo,
        string memory messageID,
        string memory body,
        string memory html,
        File[] memory fileData,
        uint256 createdAt
    ) external  returns(uint256);
    function getEmail(uint256 emailID)
    external
    view
    returns (
        Email memory
    );
    function getAllEmails() external view returns(Email[] memory);
}
