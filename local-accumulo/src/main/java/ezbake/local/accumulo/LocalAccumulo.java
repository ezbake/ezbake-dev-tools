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

package ezbake.local.accumulo;

import com.google.common.io.Files;
import org.apache.accumulo.core.client.Connector;
import org.apache.accumulo.core.client.Instance;
import org.apache.accumulo.core.client.ZooKeeperInstance;
import org.apache.accumulo.core.client.security.tokens.PasswordToken;
import org.apache.accumulo.core.security.Authorizations;
import org.apache.accumulo.core.util.Pair;
import org.apache.accumulo.minicluster.MiniAccumuloCluster;
import org.apache.accumulo.minicluster.MiniAccumuloConfig;
import org.apache.accumulo.minicluster.ServerType;
import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.net.ServerSocket;
import java.util.Arrays;
import java.util.Date;

/**
 * A significant part of this code was stolen from the MiniclusterRunner.  But this will bundle it into a jar
 * with dependencies and remove the required configuration file.  Starts Accumulo Zookeeper on port 12181 and
 * will shutdown if anyone connects to 4445
 */
public class LocalAccumulo {
    private static final String FORMAT_STRING = "  %-21s %s";

    public static void main(String args[]) throws Exception {
        Logger logger = LoggerFactory.getLogger(LocalAccumulo.class);
        final File accumuloDirectory = Files.createTempDir();

        int shutdownPort = 4445;
        MiniAccumuloConfig config = new MiniAccumuloConfig(accumuloDirectory, "strongpassword");
        config.setZooKeeperPort(12181);

        final MiniAccumuloCluster accumulo = new MiniAccumuloCluster(config);

        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                try {
                    accumulo.stop();
                    FileUtils.deleteDirectory(accumuloDirectory);
                    System.out.println("\nShut down gracefully on " + new Date());
                } catch (IOException e) {
                    e.printStackTrace();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        accumulo.start();

        printInfo(accumulo, shutdownPort);

        if (args.length > 0) {
            logger.info("Adding the following authorizations: {}", Arrays.toString(args));
            Authorizations auths = new Authorizations(args);
            Instance inst = new ZooKeeperInstance(accumulo.getConfig().getInstanceName(), accumulo.getZooKeepers());
            Connector client = inst.getConnector("root", new PasswordToken(accumulo.getConfig().getRootPassword()));
            logger.info("Connected...");
            client.securityOperations().changeUserAuthorizations("root", auths);
            logger.info("Auths updated");
        }

        // start a socket on the shutdown port and block- anything connected to this port will activate the shutdown
        ServerSocket shutdownServer = new ServerSocket(shutdownPort);
        shutdownServer.accept();

        System.exit(0);
    }

    private static void printInfo(MiniAccumuloCluster accumulo, int shutdownPort) {
        System.out.println("Mini Accumulo Cluster\n");
        System.out.println(String.format(FORMAT_STRING, "Directory:", accumulo.getConfig().getDir().getAbsoluteFile()));
        System.out.println(String.format(FORMAT_STRING, "Instance Name:", accumulo.getConfig().getInstanceName()));
        System.out.println(String.format(FORMAT_STRING, "Root Password:", accumulo.getConfig().getRootPassword()));
        System.out.println(String.format(FORMAT_STRING, "ZooKeeper:", accumulo.getZooKeepers()));

        for (Pair<ServerType, Integer> pair : accumulo.getDebugPorts()) {
            System.out.println(String.format(FORMAT_STRING, pair.getFirst().prettyPrint() + " JDWP Host:", "localhost:" + pair.getSecond()));
        }

        System.out.println(String.format(FORMAT_STRING, "Shutdown Port:", shutdownPort));

        System.out.println();
        System.out.println("  To connect with shell, use the following command : ");
        System.out.println("    accumulo shell -zh " + accumulo.getZooKeepers() + " -zi " + accumulo.getConfig().getInstanceName() + " -u root ");

        System.out.println("\n\nSuccessfully started on " + new Date());
    }

}
