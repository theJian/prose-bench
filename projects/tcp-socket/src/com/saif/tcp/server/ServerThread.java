package com.saif.tcp.server;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

/**
 * Own one accepted socket and echo complete lines to that client.
 * The listener passes the socket to the constructor and calls the
 * inherited {@link Thread#start()} to run the session on a worker thread.
 */
public class ServerThread extends Thread {
    private Socket socket;

    public ServerThread(Socket socket) {
        this.socket = socket;
    }

    /**
     * A case-insensitive {@code exit} line ends the session before any reply.
     * An I/O exception also ends the session. Both paths close the socket.
     * At end of stream, {@code readLine()} returns null and the loop keeps
     * printing {@code null} to the socket's writer.
     */
    @Override
    public void run() {
        try {
            System.out.println("Client Connected");

            BufferedReader input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            PrintWriter output = new PrintWriter(socket.getOutputStream(), true);

            while (true) {
                String inputString = input.readLine();
                if (inputString != null && inputString.toLowerCase().equals("exit")) {
                    break;
                }
                output.println(inputString);
            }
        } catch (IOException e) {
            System.out.println("Oops: " + e.getMessage());
        } finally {
            try {
                socket.close();
            } catch (IOException e) {

            }
        }

    }
}
