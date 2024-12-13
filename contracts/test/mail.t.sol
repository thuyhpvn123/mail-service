// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/mailFactory.sol";
import "../src/mailStorage.sol";
import "../src/interfaces/IEmailStorage.sol";

contract FactoryMailTest is Test {
    FactoryMail factoryMail;
    EmailStorage emailStorage;

    address deployer;
    address service = address(0x123);
    address user1 = address(0x1);
    address user2 = address(0x2);
   
    function setUp() public {
        vm.startPrank(deployer);
        factoryMail = new FactoryMail();
        vm.stopPrank();
        
    }


    function testCreateEmailStorageWithoutService() public {
        // Attempt to create EmailStorage without setting service
        vm.expectRevert("service not set yet");
        factoryMail.createEmailStorage();
    }

    function testCreateMultipleEmailStorages() public {
        vm.startPrank(deployer);
        // Set the service address
        factoryMail.setService(service);
        vm.stopPrank();
        // Create first EmailStorage
        vm.startPrank(user1);
        factoryMail.createEmailStorage();

        // Attempt to create a second EmailStorage for the same sender
        vm.expectRevert("EmailStorage already exists for sender");
        factoryMail.createEmailStorage();
        vm.stopPrank();
    }

    function testSetService() public {
        vm.startPrank(deployer);
        // Set service address
        factoryMail.setService(service);

        // Verify that service is set correctly
        assertEq(factoryMail.service(), service, "Service address should be set correctly");
        vm.stopPrank();
        vm.startPrank(user1);
        // Create an EmailStorage contract and check if service is set in it
        address emailStorageAddress = factoryMail.createEmailStorage();
        
        // Check if service is set in the created EmailStorage contract
        (bool success, bytes memory data) = emailStorageAddress.call(abi.encodeWithSignature("service()"));
        require(success, "Call to get service failed");
        
        assertEq(abi.decode(data, (address)), service, "Service in EmailStorage should match the Factory's service");
        vm.stopPrank();
    }
    function testCreateEmailStorage() public {
        vm.startPrank(deployer);
        factoryMail.setService(service);
        vm.stopPrank();
        vm.startPrank(user1);
        address emailStorageAddress = factoryMail.createEmailStorage();

        assertNotEq(emailStorageAddress, address(0), "EmailStorage address should not be zero");
        
        assertEq(factoryMail.getEmailStorageBySender(user1), emailStorageAddress, "Sender should be mapped to their EmailStorage");
        
        assertEq(factoryMail.getSenderByEmailStorage(emailStorageAddress), user1, "EmailStorage should map back to the sender");
         // Prepare file data
        vm.stopPrank();
        createEmailStorage(emailStorageAddress);
        GetByteCode(emailStorageAddress);
    }
    function createEmailStorage(address emailStorageAddress)public{
        File[] memory sampleFiles = new File[](1);
        string memory sender = "sender@example.com";
        string memory subject = "Test Subject";
        // string memory fromHeader = "From Header";
        // string memory replyTo = "replyto@example.com";
        // string memory messageID = "12345";
        // string memory body = "This is the body of the email";
        // string memory html = "<p>This is the HTML body of the email</p>";
        // uint createdAt = 1733994682;
        File memory file = File({
            contentDisposition: "attachment",
            contentID: "12345",
            contentType: "application/pdf"
        });
        
        sampleFiles[0] = file;
        // Create the email as the service address
        vm.prank(service);
        uint256 emailID = IEmailStorage(emailStorageAddress).createEmail(
            sender,
            subject,
            "From Header",
            "replyto@example.com",
            "12345",
            "This is the body of the email",
            "<p>This is the HTML body of the email</p>",
            sampleFiles,
            1733994682
        );

        vm.prank(user1);
        // Verify the email creation
        Email memory createdEmail = IEmailStorage(emailStorageAddress).getEmail(emailID);
        assertEq(createdEmail.subject, subject, "Subject does not match.");
        assertEq(createdEmail.from, sender, "Sender does not match.");
        assertEq(createdEmail.files.length, 1, "Files were not added correctly.");
        assertEq(createdEmail.files[0].contentDisposition, "attachment", "File contentDisposition mismatch.");
        vm.stopPrank();

    }
    function GetByteCode(address  emailStorageAddress)public{
         File[] memory sampleFiles = new File[](1);
        File memory file = File({
            contentDisposition: "attachment",
            contentID: "12345",
            contentType: "application/pdf"
        });
        
        sampleFiles[0] = file;
        bytes memory bytesCodeCall = abi.encodeCall(
        emailStorage.createEmail,
            ("sender@example.com",
            "Test Subject",
            "From Header",
            "replyto@example.com",
            "12345",
            "This is the body of the email",
            "<p>This is the HTML body of the email</p>",
            sampleFiles,
            1733994682)
        );
        console.log("createEmail:");
        console.logBytes(bytesCodeCall);
        console.log(
            "-----------------------------------------------------------------------------"
        );  
    }
}
