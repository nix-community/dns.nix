# SPDX-FileCopyrightText: 2021 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MIT

{ evalZone, writeTextFile }:

name: zone:
  writeTextFile {
    name = "${name}.zone";
    text = toString (evalZone name zone);
  }
