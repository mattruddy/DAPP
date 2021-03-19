pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Holder.sol";

contract Auction is ERC721Holder {

    mapping (uint256 => AuctionDetails) auctionDetails;

    struct AuctionDetails {
        ERC721 nftContract;
        bool bidIsComplete;
        address seller;
        address winningBidder;
        uint256 tokenId;
    }

    // static
    address public owner;
    uint public bidIncrement;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;

    // state
    bool public canceled;
    uint public highestBindingBid;
    address public highestBidder;
    mapping(address => uint256) public fundsByBidder;
    bool ownerHasWithdrawn;

    event LogBid(address bidder, uint bid, address highestBidder, uint highestBid, uint highestBindingBid);
    event LogWithdrawal(address withdrawer, address withdrawalAccount, uint amount);
    event LogCanceled();

    function onERC721Received(address, address from, uint256 tokenId, bytes memory) public virtual override returns(bytes4) {
       // msg.sender will always be a contract
       uint256 auctionId = uint256(keccak256(abi.encode(uint256(msg.sender), tokenId)));
        auctionDetails[auctionId] = AuctionDetails({
            nftContract: ERC721(msg.sender),
            bidIsComplete: false,
            seller: from,
            winningBidder: address(0),
            tokenId: tokenId
        });
        return this.onERC721Received.selector;
    }

    constructor() {
    }

    function getDetails(address _contractAddress, uint256 _tokenId) public view returns(AuctionDetails memory) {
        return auctionDetails[uint256(keccak256(abi.encode(_contractAddress, _tokenId)))];
    }

    // function Auction(address _owner, uint _bidIncrement, uint _startBlock, uint _endBlock, string _ipfsHash) {
    //     require(_startBlock < _endBlock);
    //     require(_startBlock >= block.number);
    //     require(_owner != 0);

    //     owner = _owner;
    //     bidIncrement = _bidIncrement;
    //     startBlock = _startBlock;
    //     endBlock = _endBlock;
    //     ipfsHash = _ipfsHash;
    // }

    // function getHighestBid() public returns (uint){
    //     return fundsByBidder[highestBidder];
    // }

    // function placeBid()
    //     public
    //     payable
    //     onlyAfterStart
    //     onlyBeforeEnd
    //     onlyNotCanceled
    //     onlyNotOwner
    //     returns (bool success)
    // {
    //     // reject payments of 0 ETH
    //     require(msg.value > 0);

    //     // calculate the user's total bid based on the current amount they've sent to the contract
    //     // plus whatever has been sent with this transaction
    //     uint newBid = fundsByBidder[msg.sender] + msg.value;

    //     // if the user isn't even willing to overbid the highest binding bid, there's nothing for us
    //     // to do except revert the transaction.
    //     require(newBid > highestBindingBid);

    //     // grab the previous highest bid (before updating fundsByBidder, in case msg.sender is the
    //     // highestBidder and is just increasing their maximum bid).
    //     uint highestBid = fundsByBidder[highestBidder];

    //     fundsByBidder[msg.sender] = newBid;

    //     if (newBid <= highestBid) {
    //         // if the user has overbid the highestBindingBid but not the highestBid, we simply
    //         // increase the highestBindingBid and leave highestBidder alone.

    //         // note that this case is impossible if msg.sender == highestBidder because you can never
    //         // bid less ETH than you've already bid.

    //         highestBindingBid = min(newBid + bidIncrement, highestBid);
    //     } else {
    //         // if msg.sender is already the highest bidder, they must simply be wanting to raise
    //         // their maximum bid, in which case we shouldn't increase the highestBindingBid.

    //         // if the user is NOT highestBidder, and has overbid highestBid completely, we set them
    //         // as the new highestBidder and recalculate highestBindingBid.

    //         if (msg.sender != highestBidder) {
    //             highestBidder = msg.sender;
    //             highestBindingBid = min(newBid, highestBid + bidIncrement);
    //         }
    //         highestBid = newBid;
    //     }

    //     LogBid(msg.sender, newBid, highestBidder, highestBid, highestBindingBid);
    //     return true;
    // }

    // function min(uint a, uint b) private returns (uint)
    // {
    //     if (a < b) return a;
    //     return b;
    // }

    // function cancelAuction()
    //     public
    //     onlyOwner
    //     onlyBeforeEnd
    //     onlyNotCanceled
    //     returns (bool success)
    // {
    //     canceled = true;
    //     LogCanceled();
    //     return true;
    // }

    // function withdraw()
    //     public
    //     onlyEndedOrCanceled
    //     returns (bool success)
    // {
    //     address withdrawalAccount;
    //     uint withdrawalAmount;

    //     if (canceled) {
    //         // if the auction was canceled, everyone should simply be allowed to withdraw their funds
    //         withdrawalAccount = msg.sender;
    //         withdrawalAmount = fundsByBidder[withdrawalAccount];

    //     } else {
    //         // the auction finished without being canceled

    //         if (msg.sender == owner) {
    //             // the auction's owner should be allowed to withdraw the highestBindingBid
    //             withdrawalAccount = highestBidder;
    //             withdrawalAmount = highestBindingBid;
    //             ownerHasWithdrawn = true;

    //         } else if (msg.sender == highestBidder) {
    //             // the highest bidder should only be allowed to withdraw the difference between their
    //             // highest bid and the highestBindingBid
    //             withdrawalAccount = highestBidder;
    //             if (ownerHasWithdrawn) {
    //                 withdrawalAmount = fundsByBidder[highestBidder];
    //             } else {
    //                 withdrawalAmount = fundsByBidder[highestBidder] - highestBindingBid;
    //             }

    //         } else {
    //             // anyone who participated but did not win the auction should be allowed to withdraw
    //             // the full amount of their funds
    //             withdrawalAccount = msg.sender;
    //             withdrawalAmount = fundsByBidder[withdrawalAccount];
    //         }
    //     }

    //     require(withdrawalAmount != 0);

    //     fundsByBidder[withdrawalAccount] -= withdrawalAmount;

    //     // send the funds
    //     require(msg.sender.send(withdrawalAmount));

    //     LogWithdrawal(msg.sender, withdrawalAccount, withdrawalAmount);

    //     return true;
    // }

    // modifier onlyOwner {
    //     require(msg.sender == owner);
    //     _;
    // }

    // modifier onlyNotOwner {
    //     require(msg.sender != owner);
    //     _;
    // }

    // modifier onlyAfterStart {
    //     require(block.number >= startBlock);
    //     _;
    // }

    // modifier onlyBeforeEnd {
    //     require(block.number <= endBlock);
    //     _;
    // }

    // modifier onlyNotCanceled {
    //     require(!canceled);
    //     _;
    // }

    // modifier onlyEndedOrCanceled {
    //     require(block.number >= endBlock || !canceled);
    //     _;
    // }
}