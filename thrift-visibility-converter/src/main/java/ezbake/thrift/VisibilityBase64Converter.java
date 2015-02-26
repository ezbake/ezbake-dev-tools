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

package ezbake.thrift;

import ezbake.base.thrift.Visibility;
import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.thrift.TException;

public class VisibilityBase64Converter {
    public static void main(String[] args) {
        try {
            Options options = new Options();
            options.addOption("d", "deserialize", false, "deserialize base64 visibility, if not present tool will serialize");
            options.addOption("v", "visibility", true, "formalVisibility to serialize, or base64 encoded string to deserialize");
            options.addOption("h", "help", false, "display usage info");

            CommandLineParser parser = new BasicParser();
            CommandLine cmd = parser.parse(options, args);

            if (cmd.hasOption("h")) {
                HelpFormatter helpFormatter = new HelpFormatter();
                helpFormatter.printHelp("thrift-visibility-converter", options);
                return;
            }

            String input = cmd.getOptionValue("v");
            boolean deserialize = cmd.hasOption("d");

            String output;
            if (deserialize) {
                if (input == null) {
                    System.err.println("Cannot deserialize empty string");
                    System.exit(1);
                }
                output = ThriftUtils.deserializeFromBase64(Visibility.class, input).toString();
            } else {
                Visibility visibility = new Visibility();
                if (input == null) {
                    input = "(empty visibility)";
                } else {
                    visibility.setFormalVisibility(input);
                }
                output = ThriftUtils.serializeToBase64(visibility);
            }
            String operation = deserialize ? "deserialize" : "serialize";
            System.out.println("operation: " + operation);
            System.out.println("input: " + input);
            System.out.println("output: " + output);
        } catch(TException | ParseException e) {
            System.out.println("An error occurred: " + e.getMessage());
            System.exit(1);
        }
    }
}
