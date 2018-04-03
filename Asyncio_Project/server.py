import sys
import asyncio
from aiohttp import ClientSession
import json
import time


ServerToPort = {
    'Alford':19735,
    'Ball':19736,
    'Hamilton':19737,
    'Holiday':19738,
    'Welsh':19739,
}

PortToServer = {
    19735:'Alford',
    19736:'Ball',
    19737:'Hamilton',
    19738:'Holiday',
    19739:'Welsh',
}

server_associate = {
    'Alford': ['Hamilton', 'Welsh'],
    'Ball': ['Holiday', 'Welsh'],
    'Hamilton': ['Alford', 'Holiday'],
    'Holiday': ['Ball', 'Hamilton'],
    'Welsh': ['Alford', 'Ball']
                    }

loop = asyncio.get_event_loop()

"""Helper functions"""
def isFloat(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

def generateAT(server_name, client_time, message):
    timeDiff = str(time.time() - float(client_time))
    if timeDiff[0] != '-':
        timeDiff = '+' + timeDiff
    return ' '.join(['AT', server_name, timeDiff, message])


"""TCP protocol use for propagate data between servers"""
class PropagateProtocol(asyncio.Protocol):
    def __init__(self, message, loop):
        self.message = message

    def connection_made(self, transport):
        transport.write(self.message.encode())
        print('Data propagate: {!r}'.format(self.message))

    def data_received(self, data):
        print('Data received: {!r}'.format(data.decode()))

    def connection_lost(self, exc):
        print('The server closed the connection')



"""TCP server protocol"""
class ServerProtocol(asyncio.Protocol):
    port_number = None
    server_name = None
    peer_name = None
    log = None
    fd = None
    client_dict = {}
    response = None

    #initial variables
    def connection_made(self, transport):
        peer_name = transport.get_extra_info('peername')
        self.peer_name = peer_name
        port_number = transport.get_extra_info('sockname')
        self.port_number = port_number[1]
        if self.port_number not in PortToServer:
            print('Socket number not in the list!')
            self.fd.write('Socket number not in the list!\n')
            transport.close()
            return
        self.server_name = PortToServer[self.port_number]

        self.log = ServerLog(self.server_name)
        self.log.startLog()
        self.fd = self.log.fd

        print('Connection establish from {}'.format(peer_name))
        self.fd.write('Connection establish from {}\n'.format(peer_name))
        self.transport = transport

    def connection_lost(self, exc):
        print('Connection dropped from {}'.format(self.peer_name))
        self.fd.write('Connection dropped from {}\n'.format(self.peer_name))


    def data_received(self, data):
        if not len(data):
            self.fd.write('Received empty data from {0}\n'.format(self.peer_name))
            print('Received empty data from {0}\n'.format(self.peer_name))
            return
        message = data.decode()
        msg_list = message.strip()
        msg_list = msg_list.split()

        if msg_list[0] == 'IAMAT':
            self.processIAMAT(msg_list)
        # if the message is propagate from server, then don't propagate it again but just log
        elif msg_list[0] == 'AT':
            self.processPropagate(msg_list)
        elif msg_list[0] == 'WHATSAT':
            coro = self.handleWHATSAT(msg_list)
            loop.create_task(coro)
        else:
            self.printError(message, 'Invalid command.\n')


        '''
        s_message = 'Sending data back to client!'
        print('Data received from client: {!r}'.format(message))
        self.fd.write('Data received from client: {!r}\n'.format(message))

        print('Send: {!r}'.format('Sending data back to client!'))
        self.transport.write(s_message.encode())
        coro = self.propagate(message=msg_list)
        loop.create_task(coro)
        '''


    @asyncio.coroutine
    def propagate(self, message):
        if not len(message):
            return

        talk_list = server_associate[self.server_name]
        coro_list = []
        for server in talk_list:
            port = ServerToPort[server]
            coro = loop.create_connection(lambda: PropagateProtocol(message, loop),
                                          '127.0.0.1', port)
            coro_list.append(coro)
        #asyncronizely propagate data to associated servers
        try:
            yield from asyncio.gather(*coro_list)
        except ConnectionRefusedError as e:
            print(e)

    def getLocation(self, location):
        ret = location.replace('+', ' +')
        ret = ret.replace('-', ' -')
        ret = ret.split()
        return ret

    def printError(self, message, error):
        msg = '? ' + message
        self.transport.write(msg.encode())
        self.fd.write('Error: {0}\nResponse: {1}\n'.format(error, msg))
        print('Error: {0}\nResponse: {1}\n'.format(error, msg))

    def processIAMAT(self, msg):
        if len(msg) != 4:
            self.printError(' '.join(msg), 'IAMAT command format is incorrect.')
            return
        location = msg[2]
        if '+' not in location and '-' not in location:
            self.printError(' '.join(msg), 'Invalid location in the input.')
            return
        location = self.getLocation(location)
        if len(location) != 2 or (not isFloat(location[0]) or not isFloat(location[1])):
            self.printError(' '.join(msg), 'Invalid location in the input.')
            return

        clientTime = msg[3]
        if not isFloat(clientTime):
            self.printError(' '.join(msg), 'Invalid time in the input.')
            return

        copy = ' '.join(msg[1:])
        atmsg = generateAT(self.server_name, clientTime, copy)
        self.client_dict.update({msg[1]: atmsg})

        self.transport.write(atmsg.encode())
        self.fd.write('Responds sent:\n' + atmsg + '\n')
        print('Responds sent:\n' + atmsg + '\n')
        coro = self.propagate(atmsg)
        loop.create_task(coro)

    def processPropagate(self, msg):
        if len(msg) != 6:
            self.printError(' '.join(msg), 'AT message format is incorrect.')
            return

        if msg[1] not in ServerToPort:
            self.printError(' '.join(msg), 'Invalid server name.')
            return
        propagate_from = msg[1]

        client = msg[3]
        clientTime = msg[5]
        if not isFloat(clientTime):
            self.printError(' '.join(msg), 'Invalid time in the input.')
            return

        client_data = ' '.join(msg)
        msg[1] = self.server_name

        if client not in self.client_dict:
            self.client_dict.update({client:client_data})
            self.fd.write('Propagation received from {0}:\n{1}\n'.format(propagate_from, client_data))
            print('Propagation received from {0}:\n{1}\n'.format(propagate_from, client_data))
            self.propagate(client_data)

        elif self.client_dict[client] != client_data:
            oldTime = self.client_dict[client].split()[5]
            if float(oldTime) < float(clientTime):
                self.client_dict.update({client:client_data})
                self.fd.write('Propagation received from {0}:\n{1}\n'.format(propagate_from, client_data))
                print('Propagation received from {0}:\n{1}\n'.format(propagate_from, client_data))
                self.propagate(client_data)

    @asyncio.coroutine
    def handleWHATSAT(self, msg):
        if len(msg) != 4:
            self.printError(' '.join(msg), 'WHATSAT message format is incorrect.')
            return

        client = msg[1]
        radius = msg[2]
        number_receive = msg[3]

        if not isFloat(radius) or not number_receive.isdigit():
            self.printError(' '.join(msg), 'WHATSAT message format is incorrect.')
            return

        radius = float(radius)
        number_receive = int(number_receive)
        if radius <= 0 or radius > 50 or number_receive <= 0 or number_receive > 20:
            self.printError(' '.join(msg), 'Radius or number of information receiving invalid')
            return

        if client not in self.client_dict:
            self.printError(' '.join(msg), 'Client not found.')
            return

        client_data = self.client_dict[client].split()
        location = self.getLocation(client_data[4])
        radius *= 1000  #Google API uses meter as unit

        url = "https://maps.googleapis.com/maps/api/place/nearbysearch/" \
              "json?location={loc1},{loc2}&radius={radius}&key={key}".format\
            (loc1=location[0], loc2=location[1], radius=radius, key='AIzaSyDK7gC7dm06PKYCiku4zNIkKI1YpwUfvGI')

        json_data = yield from self.request_google(url)
        self.processJson(json_data, number_receive, client)


    def processJson(self, data, number_receive, client):
        json_data = json.loads(data)
        json_data['results'] = json_data['results'][:number_receive]
        #separators uses for data compress for the json string
        json_string = json.dumps(json_data, indent=4, separators=(',', ': '))

        client_info = self.client_dict[client]
        client_time = client_info.split()[-1]
        response = generateAT(self.server_name, client_time, client_info) + '\n' + json_string
        response = response.rstrip('\n') + '\n\n'
        self.transport.write(response.encode())
        self.fd.write('Responds sent:\n' + response + '\n')
        print('Responds sent:\n' + response + '\n')


    async def request_google(self, url):
        async with ClientSession() as session:
            async with session.get(url) as response:
                response = await response.read()
                return response


class ServerLog():

    def __init__(self, serverName):
        self.name = serverName
        self.file = serverName + '_Log.txt'

    def startLog(self):
        self.fd = open(self.file, 'a')

    def stopLog(self):
        self.fd.close()




def main():
    if len(sys.argv) != 2:
        sys.stderr.write('Wrong argument number {0}. Should be 2.\n'.format(len(sys.argv)))
        exit(1)
    server_name = sys.argv[1]
    if server_name not in ServerToPort:
        sys.stderr.write('Invalid Server Name ' + server_name + '.\n')
        exit(1)

    port_number = ServerToPort[server_name]

    # Each client connection will create a new protocol instance
    coro = loop.create_server(ServerProtocol, '127.0.0.1', port_number)
    server = loop.run_until_complete(coro)

    # Serve requests until Ctrl+C is pressed
    print('Serving on {0}: {1}'.format(server.sockets[0].getsockname(), server_name))
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        pass

    # Close the server
    server.close()
    loop.run_until_complete(server.wait_closed())
    print('loop closed')
    loop.close()

if __name__ == '__main__':
    main()