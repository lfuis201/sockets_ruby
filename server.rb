require 'socket'

# variable para nuestro servidor que estara en el puero 8090
server = TCPServer.new 8090

#lista donde estaran los usuarios que se conecten al chat
connected_clients = []

# clase para los clientes conectados donde tendran su socket y su nombre de usuario
ConnectedClient = Struct.new(:socket, :username)

# funcion para validar si un numero de usuario existe
def valid_nickname?(nickname, connected_clients)
    connected_clients.none? {|client| client.username == nickname}
end

# funcion para hablar por el chat
def speak(msg, client, all_clients)
    all_clients.each do |other_client|
        next if other_client == client
        other_client.socket.puts msg
    end
end

# ciclo para correr el servidor
loop do
    # hilo que inicia el server para los usuarios
    Thread.start(server.accept) do |client|

        # escribimos el mensaje de bienvenida y preguntamos el nombre al usuario
        client.puts "Bienvenido a nuestro servido de chat! Cual es tu nombre?"

        # Recibimos el nombre para cada usuario y continuamos si no es nulo
        nickname = client.gets
        next if nickname.nil?

        # verificamos si el usuario es valido
        nickname = nickname.chomp
        while !(valid_nickname?(nickname, connected_clients)) do
            client.puts "Este usuario ya existe, porfavor escoge otro"
            nickname = client.gets
            next if nickname.nil?
            nickname = nickname.chomp
        end
        
        # creamos nuestara conexiones para los usuarios con su nombre
        connected_client = ConnectedClient.new(client, nickname)

        # escribimos los nombres de los usuarios que estan en el chat
        other_client_names = connected_clients.map(&:username)
        client.puts "Esstas conectado con #{connected_clients.length} otros usuarios: [#{other_client_names.join(',')}]"

        # escribimos el nombre del usuario y que se conecto alchat
        speak("*#{nickname} entro al chat*", connected_client, connected_clients)

        connected_clients << connected_client

        # ciclo para escribir en el chat
        while line = client.gets
            line = line.chomp
            speak("<#{nickname}> #{line}", connected_client, connected_clients)
        end

        # avisamos cuando un usuario se desconecta del chat
        connected_clients.delete(connected_client)
        speak("*#{nickname} salio del chat*", connected_client, connected_clients)
    end
end