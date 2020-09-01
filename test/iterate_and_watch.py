
from web3 import Web3
import json
import time



NODE = "wss://rinkeby.infura.io/ws/v3/*******INFURA_API_HERE******"
CONTRACT_ADDRESS = Web3.toChecksumAddress("0xffffffffffffffffffffffffffffffffffffffff")
ABI = """[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":false,"internalType":"string","name":"nick","type":"string"},{"indexed":false,"internalType":"uint256","name":"addSecs","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"activeTill","type":"uint256"}],"name":"onSubscribe","type":"event"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"_aindexes","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"","type":"string"}],"name":"_nindexes","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"_plans","outputs":[{"internalType":"uint256","name":"_minAddSec","type":"uint256"},{"internalType":"uint256","name":"_pricePerSec","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"_token","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"_treasure","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"_users","outputs":[{"internalType":"address","name":"_address","type":"address"},{"internalType":"string","name":"_nick","type":"string"},{"internalType":"uint256","name":"_activeTill","type":"uint256"},{"internalType":"bool","name":"_superVIP","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"string","name":"nick","type":"string"},{"internalType":"uint256","name":"addSecs","type":"uint256"}],"name":"adminSetUser","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"nick","type":"string"}],"name":"changeNick","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"checkPlans","outputs":[],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"nick","type":"string"}],"name":"getAccount","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"getActiveTill","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"nick","type":"string"}],"name":"getActiveTillByNick","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"getNick","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getPlansAmount","outputs":[{"internalType":"uint256","name":"r","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"addSecs","type":"uint256"}],"name":"getPriceForPlan","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getUsersAmount","outputs":[{"internalType":"uint256","name":"r","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"idx","type":"uint256"},{"internalType":"uint256","name":"pricePerSec","type":"uint256"},{"internalType":"uint256","name":"minAddSec","type":"uint256"}],"name":"setupPlan","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"n","type":"uint256"}],"name":"setupPlansAmount","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"}],"name":"setupToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"treasure","type":"address"}],"name":"setupTreasure","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"nick","type":"string"},{"internalType":"uint256","name":"addSecs","type":"uint256"}],"name":"subscribe","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"}]"""


# web3 = Web3(Web3.HTTPProvider(NODE))
web3 = Web3(Web3.WebsocketProvider(NODE))

CONTRACT = web3.eth.contract(address=CONTRACT_ADDRESS, abi=json.loads(ABI))

def handle_event(event):
    print(event)
    """
    AttributeDict({'args': AttributeDict({'account': '0xffffffffffffffffffffffffffffffffffffffff', 'nick': 'qqqqq', 'addSecs': 0, 'activeTill': 1598560763}), 'event': 'onSubscribe', 'logIndex': 0, 'transactionIndex': 0, 'transactionHash': HexBytes('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcc'), 'address': '0xffffffffffffffffffffffffffffffffffffffff', 'blockHash': HexBytes('0xe6a2c6a3b52fa0d8d1e2289bff4564be498579555e5ee94ec56a2d2289140978'), 'blockNumber': 7093662})
    """
    print(event["args"]["account"], event["args"]["nick"], event["args"]["addSecs"], event["args"]["activeTill"])



def log_loop(poll_interval):

    event_filter = CONTRACT.events.onSubscribe.createFilter(fromBlock="latest")

    while True:
        for event in event_filter.get_new_entries():
            handle_event(event)
        time.sleep(poll_interval)


def iterate():
    n = CONTRACT.functions.getUsersAmount().call()

    for i in range(1, n): #starting from 1 is intention
        u = CONTRACT.functions._users(i).call()
        print(u)

def main():
    iterate()
    log_loop(2)

if __name__ == '__main__':
    main()

