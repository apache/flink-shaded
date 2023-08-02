<!--
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
-->

# Apache Flink Shaded Dependencies

This repository contains a number of shaded dependencies for the [Apache Flink](https://flink.apache.org/) project.

The purpose of these dependencies is to provide a single instance of a shaded dependency in the Flink distribution, instead of each individual module shading the dependency.

Shaded dependencies contained here do not expose any transitive dependencies. They may or may not be self-contained.

When using these dependencies it is recommended to work directly against the shaded namespaces.

## Sources

We currently do not release jars containing the shaded sources due to the unanswered legal questions raised [here](https://github.com/apache/flink-shaded/issues/25).

However, it is possible to build these jars locally by cloning the repository and calling `mvn clean package -Dshade-sources`.

## About

Apache Flink is an open source project of [The Apache Software Foundation](https://apache.org/) (ASF).
