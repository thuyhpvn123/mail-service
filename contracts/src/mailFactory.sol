// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {EmailStorage} from "./mailStorage.sol";
import {IEmailStorage} from "./interfaces/IEmailStorage.sol";
import "@openzeppelin/contracts@v4.9.0/access/Ownable.sol";

contract FactoryMail is Ownable{
    // Mapping to store the EmailStorage contract for each sender
    mapping(address => address) private senderToEmailStorage;
    // Mapping to store the sender for each EmailStorage contract
    mapping(address => address) private emailStorageToSender;
    address[] allEmailStorages;
    address public service;

    event EmailStorageCreated(address indexed sender, address emailStorage);
    constructor()payable{}
    function setService(address _service)external onlyOwner {
        service = _service;
        for(uint256 i; i< allEmailStorages.length;i++){
            setService(allEmailStorages[i],_service);
        }
    }
    /**
     * @dev Creates a new EmailStorage contract for the caller.
     */
    function createEmailStorage() public returns(address) {
        require(service != address(0),"service not set yet");
        require(senderToEmailStorage[msg.sender] == address(0), "EmailStorage already exists for sender");
        EmailStorage emailStorage = new EmailStorage();
        senderToEmailStorage[msg.sender] = address(emailStorage);
        emailStorageToSender[address(emailStorage)] = msg.sender;
        allEmailStorages.push(address(emailStorage));
        emit EmailStorageCreated(msg.sender, address(emailStorage));
        setService(address(emailStorage),service);
        IEmailStorage(address(emailStorage)).setStorageOwner(msg.sender);
        return address(emailStorage);

    }
    function setService(address _emailStorage,address _service)internal{
        IEmailStorage(_emailStorage).setService(_service);
    }
    /**
     * @dev Gets the EmailStorage contract address for the sender.
     * @return The address of the EmailStorage contract.
     */
    function getEmailStorageBySender(address sender) external view returns (address) {
        return senderToEmailStorage[sender];
    }

    /**
     * @dev Gets the sender address for a given EmailStorage contract address.
     * @return The address of the sender.
     */
    function getSenderByEmailStorage(address emailStorage) external view returns (address) {
        return emailStorageToSender[emailStorage];
    }

}
