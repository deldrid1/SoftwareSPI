# Software SPI #

This library provides software-based bit-bang SPI (Serial Peripheral Interface) that can be used as an alternative to the imp API’s [**hardware.spi**](https://developer.electricimp.com/api/hardware/spi) object. This class contains the same read and write methods as the imp API.

**Note** This library only supported SPI modes 0 (CPOL 0, CPHA 0) and 1 (CPOL 0, CPHA 1) with the most significant bit sent first. Clock speed cannot be configured when using this class.

**To add this library to your project, add** `#require "SoftwareSPIMode0.device.lib.nut:0.1.0"` or `#require "SoftwareSPIMode1.device.lib.nut:0.1.0"` **to the top of your device code**

## Class Usage ##

### Constructor: SoftwareSpiMode**X**(*sclk, mosi, miso*) ###

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *sclk* | imp **pin** object | Yes | The serial clock signal |
| *mosi* | imp **pin** object | Yes | The data output |
| *miso* | imp **pin** object | Yes | The data input |

Each of the imp **pin** objects will be configured by the class.

**Note** This class does not configure or toggle a chip-select pin. Your application should take care of this functionality.

```squirrel
local sclk = hardware.pinA; // Clock
local mosi = hardware.pinB; // Master Output
local miso = hardware.pinC; // Master Input

local sspi = SoftwareSPIMode0(sclk, mosi, miso);
```

## Class Methods ##

### write(*data*) ###

This method writes the specified data to the software SPI and returns the number of bytes written.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *data* | String or blob | Yes | The data to be sent via SPI |

#### Return Value ####

Integer &mdash; the number of bytes written.

#### Example ####

```squirrel
// Configure chip select
local cs = hardware.pinD;
cs.configure(DIGITAL_OUT, 1);

// Write data to a blob
local value = blob(4);
value.writen(0xDEADBEEF, 'i');

// Write data to SPI
cs.write(0);
sspi.write(value);
cs.write(1);
```

### writeread(*data*) ###

This method writes to, and concurrently reads data from, the software SPI. The size and type of the data returned matches the size and type of the data sent.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *data* | String or blob | Yes | The data to be sent via SPI |

#### Return Value ####

String or blob &mdash; the data read from SPI.

#### Example ####

```squirrel
// Configure chip select
local cs = hardware.pinD;
cs.configure(DIGITAL_OUT, 1);

// Write and read data to/from SPI
cs.write(0);
local value = sspi.writeread("\xFF");
cs.write(1);

server.log(value);
```

### readstring(*numberOfBytes*) ###

This method reads the specified number of bytes from the software SPI and returns it as a string.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *numberOfBytes* | Integer | Yes | The number of bytes to be read from SPI |

#### Return Value ####

String &mdash; the data read from SPI.

#### Example ####

```squirrel
// Configure chip select
local cs = hardware.pinD;
cs.configure(DIGITAL_OUT, 1);

// Read 8 bytes of data from SPI and log it
cs.write(0);
local value = sspi.readstring(8);
cs.write(1);

server.log(value);
```

### readblob(*numberOfBytes*) ###

This method reads the specified number of bytes from the software SPI and returns it as a Squirrel blob.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *numberOfBytes* | Integer | Yes | The number of bytes to be read from SPI |

#### Return Value ####

Blob &mdash; the data read from SPI.

#### Example ####

```squirrel
// Configure chip select
local cs = hardware.pinD;
cs.configure(DIGITAL_OUT, 1);

// Read 2 bytes of data from SPI and log it
cs.write(0);
local value = spi.readblob(2);
cs.write(1);

server.log(value);
```

## License ##

The SoftwareSPI library is licensed under the [MIT License](./LICENSE).
