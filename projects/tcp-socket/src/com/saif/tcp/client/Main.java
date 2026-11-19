package com.saif.tcp.client;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.util.Scanner;

/**
 * Interactive client for the line-based echo server on localhost port 5000.
 * Each console line goes to the server, and the reply goes back to the
 * console. The case-insensitive {@code exit} command closes the session
 * without waiting for a reply.
 */
public class Main {

    /**
     * Run the console session. A read that waits five seconds for socket
     * data times out, prints a message, and ends the session.
     */
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        try (Socket socket = new Socket("localhost", 5000)) {
            socket.setSoTimeout(5000);
            BufferedReader input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            PrintWriter output = new PrintWriter(socket.getOutputStream(), true);
            String toServer;
            do {
                System.out.println("Enter string: ");
                toServer = scanner.nextLine();
                output.println(toServer);
                if (!toServer.toLowerCase().equals("exit")) {
                    String fromServer = input.readLine();
                    System.out.println(fromServer);
                }
            } while (!toServer.toLowerCase().equals("exit"));

        } catch (SocketTimeoutException s) {
            System.out.println("The socket timed out");
        } catch (IOException e) {
            System.out.println("Client Error: " + e.getMessage());
        }
    }
}
