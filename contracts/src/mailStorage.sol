// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts@v4.9.0/access/Ownable.sol";
import "./interfaces/IEmailStorage.sol";
contract EmailStorage is Ownable {
    mapping(uint256 => Email) private mIDToEmail;
    Email[] public emails;
    address public service;
    address public storageOwner;
    // Event for email creation
    event EmailCreated(uint256 emailID, string subject, string indexed creator);

    uint256 public emailCounter;
    constructor()payable{}
    modifier onlyService{
        require(msg.sender == service,"only service can call");
        _;
    }
    modifier onlyEmailStorageOwner{
        require(msg.sender == storageOwner,"only Email Storage Owner can call");
        _;
    }
    function setService(address _service)external onlyOwner {
        service = _service;
    }
    function setStorageOwner(address _storageOwner)external onlyOwner {
        storageOwner = _storageOwner;
    }
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
    ) external onlyService returns(uint256) {
        emailCounter++;
        // Store the email
        Email storage newEmail = mIDToEmail[emailCounter];
        newEmail.id = emailCounter;
        newEmail.subject = subject;
        newEmail.from = sender;
        newEmail.fromHeader = fromHeader;
        newEmail.replyTo = replyTo;
        newEmail.messageID = messageID;
        newEmail.body = body;
        newEmail.html = html;
        newEmail.createdAt = createdAt;
        // Add files to the email
        for (uint256 i = 0; i < fileData.length; i++) {
            newEmail.files.push(fileData[i]);
        }
        emails.push(newEmail);
        emit EmailCreated(emailCounter, subject, sender);
        return newEmail.id;
    }

    function getEmail(uint256 emailID)
        external
        view
        onlyEmailStorageOwner
        returns (
            Email memory
        )
    {
        require(emailID > 0 && emailID <= emailCounter, "Email does not exist");
        return mIDToEmail[emailID];
    }

    function getAllEmails() external view onlyEmailStorageOwner returns(Email[] memory){
        return emails;
    }
}