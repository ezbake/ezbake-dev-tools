/*   Copyright (C) 2013-2014 Computer Sciences Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License. */

package ezbake.local.redis;

import redis.embedded.RedisServer;
import redis.embedded.util.JarUtil;

import java.io.Closeable;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Random;

/**
 * User: jhastings
 * Date: 2/3/15
 * Time: 1:19 PM
 */
public class LocalRedis implements Closeable {
    public static final String REDIS_SERVER_X86_64 = "redis-server-x86_64";
    public static final String HOSTNAME = "localhost";

    private static final Random random = new Random(System.currentTimeMillis());

    private RedisServer redisServer;
    private int redisPort;

    public LocalRedis() throws IOException {
        this(getFreePort());
    }

    public LocalRedis(int port) throws IOException {
        this.redisPort = port;

        String osName = System.getProperty("os.name").toLowerCase();
        String osArch = System.getProperty("os.arch").toLowerCase();
        if ((osName.contains("nix") || osName.contains("nux") || osName.contains("aix")) && osArch.contains("64")) {
            redisServer = new RedisServer(JarUtil.extractExecutableFromJar(REDIS_SERVER_X86_64), port);
        } else {
            redisServer = new RedisServer(port);
        }
        redisServer.start();
    }

    @Override
    public void close() throws IOException {
        if (redisServer != null)  {
            try {
                redisServer.stop();
            } catch (InterruptedException e) {
                throw new IOException(e);
            }
        }
    }

    public int getPort() {
        return redisPort;
    }


    protected static int getRandomPort(int start, int end) {
        return random.nextInt((end - start) + 1) + start;
    }

    protected static int getFreePort() throws IOException {
        int portNumber = 0;
        boolean done = false;
        while (!done) {
            portNumber = getRandomPort(10000,40000);
            if (isFree(portNumber)) {
                done = true;
            }
        }
        return portNumber;
    }

    protected static boolean isFree(int port) {
        return serverSocketIsFree(port) && clientSideSocketIsFree(port);
    }

    protected static boolean clientSideSocketIsFree(int port) {
        Socket clientSocket = null;
        try {
            clientSocket = new Socket(HOSTNAME, port);
        } catch (final IOException e) {
            return true;
        } finally {
            if (clientSocket != null) {
                try {
                    clientSocket.close();
                } catch (final IOException e) {
                    // Should never happen
                }
            }
        }
        return false;
    }

    protected static boolean serverSocketIsFree(int port) {
        ServerSocket socket = null;
        try {
            socket = new ServerSocket();
            socket.setReuseAddress(true);
            socket.bind(new InetSocketAddress(port));
            socket.getLocalPort();
            return true;
        } catch (final IOException e) {
            return false;
        } finally {
            try {
                if (socket != null) {
                    socket.close();
                }
            } catch (final IOException e) {
                // should never happen
            }
        }
    }
}
