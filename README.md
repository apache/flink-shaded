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

## Cryptographic Software Notice

This distribution includes cryptographic software.  The country in
which you currently reside may have restrictions on the import,
possession, use, and/or re-export to another country, of
encryption software. BEFORE using any encryption software, please
check your country's laws, regulations and policies concerning the
import, possession, or use, and re-export of encryption software, to
see if this is permitted. See http://www.wassenaar.org for
more information.

The Apache Software Foundation has classified this software as Export
Commodity Control Number (ECCN) 5D002, which includes information
security software using or performing cryptographic functions with
asymmetric algorithms. The form and manner of this Apache Software
Foundation distribution makes it eligible for export under the
"publicly available" Section 742.15(b) exemption (see the BIS Export
Administration Regulations, Section 742.15(b)) for both object code
and source code.

The following provides more details on the included cryptographic
software:

  * Apache Flink Shaded publishes flink-shaded-netty-tcnative-dynamic
    (linking against a system-provided OpenSSL) and
    flink-shaded-netty-tcnative-static (embedding Google's BoringSSL
    library) as convenience binaries on Maven Central, for use as
    Apache Flink's optional OpenSSL-based SSL engine. The source
    release contains build scripts only; the cryptographic libraries
    are included in the compiled artifacts.

## About

Apache Flink is an open source project of [The Apache Software Foundation](https://apache.org/) (ASF).
