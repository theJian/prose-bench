package com.saif.tcp.server;

import java.io.IOException;
import java.net.ServerSocket;

/**
 * Listen for TCP clients on port 5000. The accept loop hands each accepted
 * socket to its own {@link ServerThread}. See {@link ServerThread#run()}
 * for the line protocol and the conditions that close a connection.
 */
public class Main {

    /** Accept connections until listening or accepting raises an I/O error. */
    public static void main(String[] args) {
        try (ServerSocket serverSocket = new ServerSocket(5000)) {
            while (true) {
                new ServerThread(serverSocket.accept()).start();
            }

        } catch (IOException e) {
            System.out.println("Server Error: " + e.getMessage());
        }
    }
}
