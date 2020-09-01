pragma solidity ^0.6.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

// import "@openzeppelin/contracts/token/IERC20.sol";



contract Accounting is Ownable {

    event onSubscribe(address indexed account, string nick, uint addSecs, uint activeTill);

    using SafeMath for uint256;

    struct User {
        address _address;
        string _nick;
        uint _activeTill;
        bool _superVIP;
    }

    struct Plan {
        uint _minAddSec;
        uint _pricePerSec;
    }


    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));


    User[] public _users;
    Plan[] public _plans;

    address public _token;
    address public _treasure;

    mapping (address => uint256) public _aindexes;
    mapping (string => uint256) public _nindexes;


    constructor () public {
        _users.push(User(address(0x0), "", 0, false));
    }

    function setupToken(address token) public onlyOwner {
        _token = token;
    }

    function setupTreasure(address treasure) public onlyOwner {
        _treasure = treasure;
    }

    function setupPlansAmount(uint n) public onlyOwner {
        delete _plans;
        for (uint i = 0; i < n; i++) {
            _plans.push();
        }
    }

    function getPlansAmount() public view returns (uint r) {
        r = _plans.length;
    }

    function setupPlan(uint idx, uint pricePerSec, uint minAddSec) public onlyOwner {
        _plans[idx]._minAddSec = minAddSec;
        _plans[idx]._pricePerSec = pricePerSec;
    }

    function _safeTransfer(address from, address to, uint value) private {
        require(_token != address(0x0));
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(SELECTOR, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FAILED');
    }

    function getUsersAmount() public view returns (uint r) {
        r = _users.length;
    }


    function getNick(address account) public view returns (string memory) {
    	uint idx = _aindexes[account];
    	return _users[idx]._nick;
    }

    function getAccount(string memory nick) public view returns (address) {
        uint idx = _nindexes[nick];
        return _users[idx]._address;
    }

    function getActiveTill(address account) public view returns (uint) {
    	uint idx = _aindexes[account];
    	return _users[idx]._activeTill;
    }

    function getActiveTillByNick(string memory nick) public view returns (uint) {
        uint idx = _nindexes[nick];
        return _users[idx]._activeTill;
    }

    function _addTime(User storage user, uint addSecs) private  {
        if (user._activeTill < now) {
            user._activeTill = now;
        }
        user._activeTill = user._activeTill.add(addSecs);
    }

    function _stringsEqual(string storage _a, string memory _b) view internal returns (bool) {
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b);
        if (a.length != b.length)
            return false;

        for (uint i = 0; i < a.length; i++)
            if (a[i] != b[i])
                return false;
        return true;
    }

    function _setupNick(User storage user, string memory nick) private {
        assert(user._address != address(0x0)); //not default User
        if (_stringsEqual(user._nick, nick)) {
            return;
        }

        require(_nindexes[nick] == 0, "Nick is in use");
        uint idx = _aindexes[user._address];

        if (bytes(user._nick).length > 0) {
            assert(_nindexes[user._nick] == idx); //indexes is consistent
            delete _nindexes[user._nick];
        }

        user._nick = nick;
        _nindexes[nick] = idx;
    }

    function _setUser(address account, string memory nick, uint addSecs) private {
        assert(account != address(0x0));

        uint idx = _aindexes[account];

        if (idx == 0) {
            idx = _users.length;
            _users.push(User(account, "", 0, false));
            _aindexes[account] = idx;
        }

        User storage user = _users[idx];
        _addTime(user, addSecs);

        if (bytes(nick).length > 0)
            _setupNick(user, nick);

        emit onSubscribe(account, user._nick, addSecs, user._activeTill);
    }

    function adminSetUser(address account, string memory nick, uint addSecs) public onlyOwner {
        require(account != address(0x0));
        _setUser(account, nick, addSecs);
    }

    function checkPlans() public view {
        uint prevMinAddSec = 0;
        uint prevPricePerSec = 0;
        for (uint i = 0; i < _plans.length; i++) {
            require(i == _plans.length-1 || _plans[i]._minAddSec > 0);
            require(prevMinAddSec == 0 || _plans[i]._minAddSec < prevMinAddSec);
            require(_plans[i]._pricePerSec > prevPricePerSec);
            prevPricePerSec = _plans[i]._pricePerSec;
            prevMinAddSec = _plans[i]._minAddSec;
        }
    }

    function getPriceForPlan(uint addSecs) public view returns (uint) {
        require(_plans.length > 0);
        checkPlans();

        uint n = _plans.length-1;

        if (addSecs == 0) {
            return _plans[n]._pricePerSec;
        }

        for (uint i = 0; i < n; i++) {
            if (addSecs >= _plans[i]._minAddSec) {
                return _plans[i]._pricePerSec;
            }
        }
        return _plans[n]._pricePerSec;
    }


    function subscribe(string memory nick, uint256 addSecs) public {

        address account = msg.sender;
        require(account != address(0x0));
        require(_treasure != address(0x0));

        uint pricePerSec = getPriceForPlan(addSecs);
        uint amount = addSecs.mul(pricePerSec);

        if (amount > 0) {
            _safeTransfer(account, _treasure, amount);
        }

        _setUser(account, nick, addSecs);
    }


    function changeNick(string memory nick) public {
        address account = msg.sender;
        require(account != address(0x0));
        require(bytes(nick).length > 0);
        uint idx = _aindexes[account];
        require(idx > 0);
        _setupNick(_users[idx], nick);
    }
}




