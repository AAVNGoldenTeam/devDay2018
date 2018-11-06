pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract SupplyChain {
    struct Producer {
        address owner;
        string name;
    }
    
    struct Vendor {
        address owner;
        string name;
    }
    
    struct OwnerShipHist {
        address owner;
        uint256 time;
    }
    
    struct Product {
        string name;
        address currentOwner;
        uint price;
        uint nHist;
        mapping(uint => OwnerShipHist) history; 
    }
    
    Producer[] private producers;
    Vendor[] private vendors;
    Product[] private products;
    
    constructor()public{
        v1HardCode();
    }
    
    //function registerProducer(string _name) public 
    function v1HardCode() private {
        producers.push(Producer(0xca35b7d915458ef540ade6068dfe2f44e8fa733c, "Dummy"));
        producers.push(Producer(0xF4136D9Dc89Df27F020445b4eF30a625fED92B48, "Vinamilk"));
        producers.push(Producer(0xEC15ACA0C473B2A09F3010127e037527E74C3fF4, "Thai Duong"));
        vendors.push(Vendor(0xcBEa161c69F43E32AA8f7FF97624CcF68204eEfF, "Phuong"));
        vendors.push(Vendor(0xdD70CD7B58CA8061429209bA8Df6100b0C0B0425, "Thanh"));
    }
    
    function createProduct(string _name, uint _price) public {
        require(isProducer(msg.sender), "Only producer can produce product.");
        products.push(Product(_name, msg.sender, _price, 0));
        Product storage p = products[products.length-1];
        p.history[p.nHist++] = OwnerShipHist(msg.sender, now);
    }
    
    function getProducts() public view returns (string[], address[], uint[]) {
        string[] memory names = new string[](products.length);
        address[] memory currentOwners = new address[](products.length);
        uint[] memory prices = new uint[](products.length);
        for (uint i = 0; i < products.length; i++) {
            names[i] = products[i].name;
            currentOwners[i] = products[i].currentOwner;
            prices[i] = products[i].price;
            
        }
        return (names, currentOwners, prices);
    }
    
    function getProductsBySender() public view returns (uint, string[], address[], uint[]) {
        uint count = 0;
        string[] memory names = new string[](products.length);
        address[] memory currentOwners = new address[](products.length);
        uint[] memory prices = new uint[](products.length);
        for (uint i = 0; i < products.length; i++) {
            if (products[i].currentOwner == msg.sender) {
                names[i] = products[i].name;
                currentOwners[i] = products[i].currentOwner;
                prices[i] = products[i].price;
                count++;
            }
        }
        return (count, names, currentOwners, prices);
    }
    
    //TODO
    function deposit() public payable {
        require(isVendor(msg.sender), "Only vendor can deposit money");
        
    }
    
    function buyProduct(string _productName) public payable {
        int i = findProduct(_productName);
        require(i != -1, "No such product");
        uint index = uint(i);
        require(uint(msg.value) == products[index].price, "Insufficient funds");
        require(isVendor(msg.sender), "Only vendor can buy product");
        
        products[index].currentOwner.transfer(uint(msg.value));
        products[index].currentOwner = msg.sender;
        products[index].history[products[index].nHist++] = OwnerShipHist(msg.sender, now);
    }
    
    
    function findProduct(string _productName) private returns (int) {
        for (uint i = 0; i < products.length; i++) {
            if (equals(products[i].name, _productName)) {
                return int(i);
            }
        }
        return -1; // not found
    }
    
    
    
    function isProducer(address _sender) private returns (bool) {
        for(uint i = 0; i < producers.length; i++) {
            if(producers[i].owner == _sender) {
                return true;
            }
        }
        return false;
    }
    
    function isVendor(address _sender) private returns (bool) {
        for(uint i = 0; i < vendors.length; i++) {
            if(vendors[i].owner == _sender) {
                return true;
            }
        }
        return false;
    }
    
    function equals(string storage s1, string s2) private returns (bool) {
        return keccak256(s1) == keccak256(s2);
    }
}