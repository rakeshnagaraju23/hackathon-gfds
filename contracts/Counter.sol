//SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.7;

error WeightExceeded();
error NotEnoughCoins();
error NotEnoughFundInAccount(uint256 _currentBalance);
error BalanceAmountShouldBeGreaterThanWithdrawlAmount(uint256 _currentBalance, uint256 _withdrawAmt);
error TransactionFailed();

contract Counter {
    struct Flyer {
        address flyerAddress;
        string startLocation;
        string destLocation;
        uint256 weightAllowed;
        uint256 pricePerKg;
        string phone;
        string dateOfTravel;
        string anySpecification;
    }

    struct Parcel {
        address senderAddress;
        uint256 parcelWeight;
        string customerPhone;
        string datesOfTravel;
        string parcelDetail;
    }

    struct Trasaction {
        uint256 transactionId;
        uint256 flyerId;
        uint256 senderId;
        uint256 totalAmount;
        bool deliveryConfirmed;
    }

    uint256 private flyerCounter;
    uint256 private parcelCounter;
    uint256 private transactionCounter;
    mapping(uint256 => Flyer) private flyer;
    mapping(uint256 => Parcel) private parcel;
    mapping(uint256 => Trasaction) private transaction;
    mapping(address => uint256) private balances;

    event FlyerAdded(
        address flyerAddress,
        string startLocation,
        string destLocation,
        uint256 weightAllowed,
        uint256 pricePerKg,
        string phone,
        string dateOfTravel,
        string anySpecification
    );
    event ParcelSender(
        address senderAddress,
        uint256 parcelWeight,
        string senderPhone,
        string datesOfTravel,
        string parcelDetail
    );
    event ParcelBooked(
        uint256 transactionId,
        uint256 flyerId,
        uint256 senderId,
        uint256 totalAmount,
        bool deliveryConfirmed
    );

    /* Add a new Flyer */
    function addFlyer(
        address _flyerAddress,
        string memory _startLocation,
        string memory _destLocation,
        uint256 _weightAllowed,
        uint256 _pricePerKg,
        string memory _phone,
        string memory _dateOfTravel,
        string memory _anySpecification
    ) public returns (uint256) {
        flyer[flyerCounter] = Flyer(
            _flyerAddress,
            _startLocation,
            _destLocation,
            _weightAllowed,
            _pricePerKg,
            _phone,
            _dateOfTravel,
            _anySpecification
        );
        emit FlyerAdded(
            _flyerAddress,
            _startLocation,
            _destLocation,
            _weightAllowed,
            _pricePerKg,
            _phone,
            _dateOfTravel,
            _anySpecification
        );
        return flyerCounter++;
    }

    /* Add Parcel Sender Details */
    function addParcelSender(
        address _senderAddress,
        uint256 _parcelWeight,
        string memory _senderPhone,
        string memory _datesOfTravel,
        string memory _parcelDetail
    ) public returns (uint256) {
        parcel[parcelCounter] = Parcel(
            _senderAddress,
            _parcelWeight,
            _senderPhone,
            _datesOfTravel,
            _parcelDetail
        );
        emit ParcelSender(
            _senderAddress,
            _parcelWeight,
            _senderPhone,
            _datesOfTravel,
            _parcelDetail
        );
        return parcelCounter++;
    }

    /* Book Parcel To Be Sent */
    function bookParcel(
        uint256 _flyerId,
        address _senderAddress,
        uint256 _parcelWeight,
        string memory _senderPhone,
        string memory _datesOfTravel,
        string memory _parcelDetail
    ) public payable {
        uint256 totalAmount = _parcelWeight * flyer[_flyerId].pricePerKg;
        if (_parcelWeight > flyer[_flyerId].weightAllowed) revert WeightExceeded();
        if (totalAmount > msg.value) revert NotEnoughCoins();

        uint256 senderId = addParcelSender(
            _senderAddress,
            _parcelWeight,
            _senderPhone,
            _datesOfTravel,
            _parcelDetail
        );
        transaction[transactionCounter] = Trasaction(
            transactionCounter,
            _flyerId,
            senderId,
            totalAmount,
            false
        );

        emit ParcelBooked(transactionCounter, _flyerId, senderId, totalAmount, false);
    }

    /* Confirm Delivery of a Parcel */
    function confirmDelivery(uint256 _transactionId) external {
        transaction[_transactionId].deliveryConfirmed = true;
        address flyerAddress = flyer[transaction[_transactionId].flyerId].flyerAddress;
        balances[flyerAddress] += transaction[_transactionId].totalAmount;
    }

    /* Function to Withdraw Given Balance */
    function withdraw(uint256 _amtWithdraw) public payable {
        if (balances[msg.sender] == 0) revert NotEnoughFundInAccount(balances[msg.sender]);
        if (balances[msg.sender] < _amtWithdraw) revert BalanceAmountShouldBeGreaterThanWithdrawlAmount(balances[msg.sender], _amtWithdraw);

        balances[msg.sender] -= _amtWithdraw;
        (bool success, ) = msg.sender.call{value: _amtWithdraw}("");
         if (!success) {
            revert TransactionFailed();
        }
    }

    /* Get Flyers Based On Id */
    function getFlyers(uint256 _flyerId) public view returns (Flyer memory) {
        return flyer[_flyerId];
    }

    /* Get Balance Of a Given User */
    function getUserBalance(address user) public view returns (uint256) {
        return balances[user];
    }

    uint256 counter;
    address owner;

    constructor() {
        counter = 0;
        owner = msg.sender;
    }

    event counterReset(uint256 oldCounter);

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }

    function add() public {
        counter++;
    }

    function subtract() public {
        counter--;
    }

    function reset() public onlyOwner {
        emit counterReset(counter);
        counter = 0;
    }

    function getCurrentCount() public view returns (uint256) {
        return counter;
    }

    function getFlyerCounter() public view returns (uint256) {
        return flyerCounter;
    }
}
