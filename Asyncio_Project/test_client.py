import asyncio
import json
import sys

"""TCP echo client protocol"""
class EchoClientProtocol(asyncio.Protocol):
    def __init__(self, message, loop):
        self.message = message
        self.loop = loop

    def connection_made(self, transport):
        transport.write(self.message.encode())
        print('Data sent: {!r}'.format(self.message))
        self.transport = transport

    def data_received(self, data):
        print('Data received: {!r}'.format(data.decode()))

    def connection_lost(self, exc):
        print('The server closed the connection')
        print('Stop the event loop')
        self.loop.stop()

loop = asyncio.get_event_loop()
message = 'IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 1479413884.392014450'
message2 = 'WHATSAT kiwi.cs.ucla.edu 10 5'
coro = loop.create_connection(lambda: EchoClientProtocol(message, loop),
                              '127.0.0.1', 19736)
coro2 = loop.create_connection(lambda: EchoClientProtocol(message2, loop),
                              '127.0.0.1', 19736)
loop.run_until_complete(coro)
loop.create_task(coro2)
loop.run_forever()
print('loop closed')
loop.close()