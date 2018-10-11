// slight modification of https://github.com/electricimp/SoftwareSPI to provide SPI mode 1
// MIT License
//
// Copyright (c) 2017 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// Big banging SPI class
class SoftwareSPIMode1 {

    static VERSION = "0.1.0";

    // Same as imp error messages
    static ERROR_BAD_PARAMS_WRITE     = "bad parameters to spi.write(data)";
    static ERROR_BAD_PARAMS_WRITEREAD = "bad parameters to spi.writeread(data)";

    // SCLK, MOSI, MISO pin variables
    _sclk  = null;
    _mosi = null;
    _miso = null;

    constructor(sclk, mosi, miso) {
        _sclk = sclk;
        _mosi = mosi;
        _miso = miso;

        // Configure pins
        _sclk.configure(DIGITAL_OUT, 0);
        _mosi.configure(DIGITAL_OUT, 0);
        _miso.configure(DIGITAL_IN);
    }

    function write(data) {
        //Local variables to speed things up
        local cw = _sclk.write.bindenv(_sclk);
        local dw = _mosi.write.bindenv(_mosi);
        local mask;

        if (typeof data == "string") {
            local b = blob(data.len());
            b.writestring(data);
            data = b
        }

        if (typeof data != "blob") throw ERROR_BAD_PARAMS_WRITE;

        foreach (byte in data) {
            for (mask = 0x80; mask > 0; mask = mask >> 1) {
                cw(1);
                dw(byte & mask);
                cw(0);
            }
        }

        return data.len();
    }

    function writeread(data) {
        //Local variables to speed things up
        local cw = _sclk.write.bindenv(_sclk);
        local dw = _mosi.write.bindenv(_mosi);
        local dr = _miso.read.bindenv(_miso);
        local sleep = imp.sleep.bindenv(imp);
        local mask;

        local read_val = 0;
        local data_len = data.len();
        local read_blob = blob(data_len);
        local read_blobw = read_blob.writen.bindenv(read_blob)
        local rtnString = false;

        if (typeof data == "string") {
            rtnString = true;
            local b = blob(data_len);
            b.writestring(data);
            data = b
        }

        if (typeof data != "blob") throw ERROR_BAD_PARAMS_WRITEREAD;

        foreach (byte in data) {
            for(mask = 0x80; mask > 0; mask = mask >> 1) {
                cw(1);
                dw(byte & mask);
                sleep(0.000001)
                // read the last byte
                read_val = (read_val << 1) | (dr() ? 1 : 0);
                cw(0);
            }
            read_blobw(read_val, 'b');
            read_val = 0;
        }

        if (rtnString) {
            return read_blob.tostring();
        } else {
            return read_blob;
        }
    }

    function readstring (numChars) {
        return readblob(numChars).tostring();
    }

    function readblob(numChars){
        // Local variables to speed things up
        local cw = _sclk.write.bindenv(_sclk);
        local dr = _miso.read.bindenv(_miso);
        local sleep = imp.sleep.bindenv(imp);
        local mask;

        local read_blob = blob(numChars);

        for (local a = 0; a < numChars; a++) {
            local byte = 0;
            for (local b = 0; b < 8; b++) {
                cw(1);
                sleep(0.000001) //allow some time for our slave to update its data //TODO: Is this necessary?
                byte = (byte << 1) | (dr() ? 1 : 0);
                cw(0);
            }
            read_blob.writen(byte, 'b');
        }

        read_blob.seek(0, 'b');
        return read_blob;
    }
}
                        //   sclk,          mosi,          miso
PORT_SPI <- SoftwareSPI(hardware.pinU, hardware.pinN, hardware.pinL);  // CLOCK_IDLE_LOW | CLOCK_2ND_EDGE
