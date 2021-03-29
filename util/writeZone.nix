# SPDX-FileCopyrightText: 2021 Kirill Elagin <kirelagin@gmail.com>
#
# SPDX-License-Identifier: MIT

{ evalZone, writeTextFile }:

name: zone:
  writeTextFile {
    name = "${name}.zone";
    text = toString (evalZone name zone);
  }
