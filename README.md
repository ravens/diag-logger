# diag-logger
DIAG protocol logger for QC chipsets in Python.

This is a PoC for recovering events at the RRC/NAS level from a phone connected to a test eNB, logging them for post-processing. 

At the moment the script is able to activate the logging on a rooted phone (nexus 5/nexus 5x) and is able to parse a very small subset of LTE frames - basically MIB and some RRC messages (which is what I need at the moment). NAS messages would be probably a great addition.

Some ideas/todos : 
* add a websocket to pump info
* fix concatenated messages parsing by check the length advertized in the ota header. At the moment only the first one is parsed.   
* dump the binary into a PCAP using DLT like the [srsLTE](https://github.com/srsLTE/srsLTE/blob/4762483396fdaff86b16988a0e2527334fc57136/lib/include/srslte/common/pcap.h) folks, or use GSMTAP like diag-parser.

[13/02/2019] If you look for a more mature project [Scat](https://github.com/fgsect/scat) is probably what you should look for.. 

## related projects

* [Osmocom wiki](https://osmocom.org/projects/quectel-modems/wiki/Diag) : a wiki page describing the protocol. 
* [Snoopsnitch](https://opensource.srlabs.de/projects/snoopsnitch) : an opensource project focused on collecting data on existing network by performing passive and active tests and recovering the event through the DIAG protocol on a rooted Android phone.
* [diag-parser](https://github.com/moiji-mobile/diag-parser) : an opensource project focused on reading data from a QC embedded modem and converting 2G,3G and LTE radio messages to GSMTAP format to make them parseable by Wireshark.
* [DiagLibrary](https://github.com/sanjaywave/DiagLibrary) : a JNI library that implement a DIAG protocol parser under C code to be used under Android or Linux.
* [USB-device-fuzzing](https://github.com/ollseg/usb-device-fuzzing) : an opensource, simple USB fuzzer using pyusb and scapy to implement the DIAG protocol.
* [Pycrate](https://github.com/P1sec/pycrate) : the successor of the libmich library that is used to encode and decode data structures, including ASN.1 used in cellular protocol.
* [Scat](https://github.com/fgsect/scat) : Same approach ad this project, but extending support to Samsung baseband and with better code (parsing using Osmocom libraries). An output toward gsmtap over UDP is buildin.

## hardware

A rooted phone is typically needed. I am using stock Google Nexus 5 (and trying with Nexus 5x) with latest official firmware.

The procedure for rooting typically involves the following:
* (nexus 5x and new android OS 7/8) : activate developer mode and autorized bootloader unlock
* unlock bootloader
* flash TWRP
* flash latest, beta Magisk with TWRP
* reboot a certain number of times

using adb shell you should see a '/dev/diag' device enabled on the system when using su. 

In order to have access to that device through a PC, we perform a small command in root (as indicated on that [Reddit thread](https://www.reddit.com/r/nexus5x/comments/3rranb/enabling_usb_diagnostic_mode/) : 

```
adb shell
su -c 'setprop sys.usb.config diag,adb'
```

The device will disconnect and reconnect under a new USB vendor and product ID, presenting a CDC ACM interface (or several, if the AT modem is also exposed, this is the case on the Nexus 5x, but not on the Nexus 5, YMMV).

This does not survive a reboot.

## dependencies

The script is requiring a couple of python dependencies. Typically :
```
pip install pyusb
pip install scapy
git clone https://github.com/mitshell/CryptoMobile && cd CryptoMobile && python setup.py install
git clone https://github.com/P1sec/pycrate && cd pycrate && python setup.py install
```

I am using pycrate to parse ASN1 frames, and scapy to decode the packets from the usb bus (exactly like the USB fuzzing project mentionned before).

## how to run

Edit your USB device vendor and product ID within the script (right now it expects a Nexus 5)
Then to execute :
```
./diag-logger.py
```

The typical output should look like (using my nexus5 on 214-03) :
```
{"rrc_version": 113, "raw": "6848500705460014d0081b5188020610b089846c24775000000000007a627e100015001500c1b000008899a931e300016501ea0b80020264", "timestamp": 1535703269.569585, "pci": 357, "earfcn": 3050, "message": ["c1", ["systemInformationBlockType1", {"systemInfoValueTag": 23, "si-WindowLength": "ms10", "nonCriticalExtension": {"nonCriticalExtension": {"cellSelectionInfo-v920": {"q-QualMin-r9": -34}}}, "freqBandIndicator": 7, "cellAccessRelatedInfo": {"csg-Indication": false, "plmn-IdentityList": [{"cellReservedForOperatorUse": "notReserved", "plmn-Identity": {"mnc": [0, 3], "mcc": [2, 1, 4]}}], "intraFreqReselection": "allowed", "cellBarred": "notBarred", "cellIdentity": [85248, 28], "trackingAreaCode": [1350, 16]}, "p-Max": 23, "schedulingInfoList": [{"si-Periodicity": "rf8", "sib-MappingInfo": ["sibType3"]}, {"si-Periodicity": "rf64", "sib-MappingInfo": ["sibType4"]}, {"si-Periodicity": "rf64", "sib-MappingInfo": ["sibType5"]}, {"si-Periodicity": "rf64", "sib-MappingInfo": ["sibType6"]}, {"si-Periodicity": "rf64", "sib-MappingInfo": ["sibType7"]}], "cellSelectionInfo": {"q-RxLevMin": -64}}]], "type": "BCCH-DL-SCH-Message", "rrc_release": 10}
{"rrc_version": 113, "raw": "40050c144d01380000", "timestamp": 1535703270.520744, "pci": 357, "earfcn": 3050, "message": ["c1", ["paging", {"pagingRecordList": [{"cn-Domain": "cs", "ue-Identity": ["s-TMSI", {"m-TMSI": [3242512403, 32], "mmec": [80, 8]}]}]}]], "type": "PCCH-Message", "rrc_release": 10}
{"rrc_version": 113, "raw": "40040e2eef22c00000", "timestamp": 1535703273.080744, "pci": 357, "earfcn": 3050, "message": ["c1", ["paging", {"pagingRecordList": [{"cn-Domain": "ps", "ue-Identity": ["s-TMSI", {"m-TMSI": [3807310380, 32], "mmec": [64, 8]}]}]}]], "type": "PCCH-Message", "rrc_release": 10}
{"rrc_version": 113, "raw": "40030dbeea55d00000", "timestamp": 1535703276.921346, "pci": 357, "earfcn": 3050, "message": ["c1", ["paging", {"pagingRecordList": [{"cn-Domain": "ps", "ue-Identity": ["s-TMSI", {"m-TMSI": [3689850205, 32], "mmec": [48, 8]}]}]}]], "type": "PCCH-Message", "rrc_release": 10}
{"rrc_version": 113, "raw": "40028fb80fa1600000", "timestamp": 1535703277.560968, "pci": 357, "earfcn": 3050, "message": ["c1", ["paging", {"pagingRecordList": [{"cn-Domain": "ps", "ue-Identity": ["s-TMSI", {"m-TMSI": [4219533846, 32], "mmec": [40, 8]}]}]}]], "type": "PCCH-Message", "rrc_release": 10}
{"rrc_version": 113, "raw": "40048dc4d100700000", "timestamp": 1535703280.120625, "pci": 357, "earfcn": 3050, "message": ["c1", ["paging", {"pagingRecordList": [{"cn-Domain": "ps", "ue-Identity": ["s-TMSI", {"m-TMSI": [3696037895, 32], "mmec": [72, 8]}]}]}]], "type": "PCCH-Message", "rrc_release": 10}
{"rrc_version": 113, "raw": "40048e016cafb00000", "timestamp": 1535703280.76074, "pci": 357, "earfcn": 3050, "message": ["c1", ["paging", {"pagingRecordList": [{"cn-Domain": "ps", "ue-Identity": ["s-TMSI", {"m-TMSI": [3759590139, 32], "mmec": [72, 8]}]}]}]], "type": "PCCH-Message", "rrc_release": 10}
{"rrc_version": 113, "raw": "40058e4d4762200000", "timestamp": 1535703281.400979, "pci": 357, "earfcn": 3050, "message": ["c1", ["paging", {"pagingRecordList": [{"cn-Domain": "ps", "ue-Identity": ["s-TMSI", {"m-TMSI": [3839129122, 32], "mmec": [88, 8]}]}]}]], "type": "PCCH-Message", "rrc_release": 10}
{"rrc_version": 113, "raw": "40038fc3aebc600000", "timestamp": 1535703285.880717, "pci": 357, "earfcn": 3050, "message": ["c1", ["paging", {"pagingRecordList": [{"cn-Domain": "ps", "ue-Identity": ["s-TMSI", {"m-TMSI": [4231719878, 32], "mmec": [56, 8]}]}]}]], "type": "PCCH-Message", "rrc_release": 10}
{"rrc_version": 113, "raw": "40030e8870e3e00000", "timestamp": 1535703286.52068, "pci": 357, "earfcn": 3050, "message": ["c1", ["paging", {"pagingRecordList": [{"cn-Domain": "ps", "ue-Identity": ["s-TMSI", {"m-TMSI": [3901165118, 32], "mmec": [48, 8]}]}]}]], "type": "PCCH-Message", "rrc_release": 10}
{"rrc_version": 113, "raw": "41030e8870e3e028f04743e9028dd6ca53f800000000", "timestamp": 1535703288.440436, "pci": 357, "earfcn": 3050, "message": ["c1", ["paging", {"pagingRecordList": [{"cn-Domain": "ps", "ue-Identity": ["s-TMSI", {"m-TMSI": [3901165118, 32], "mmec": [48, 8]}]}, {"cn-Domain": "ps", "ue-Identity": ["s-TMSI", {"m-TMSI": [4031202281, 32], "mmec": [40, 8]}]}, {"cn-Domain": "cs", "ue-Identity": ["s-TMSI", {"m-TMSI": [3714884927, 32], "mmec": [40, 8]}]}]}]], "type": "PCCH-Message", "rrc_release": 10}
{"rrc_version": 113, "raw": "40030d369426400000", "timestamp": 1535703289.719933, "pci": 357, "earfcn": 3050, "message": ["c1", ["paging", {"pagingRecordList": [{"cn-Domain": "ps", "ue-Identity": ["s-TMSI", {"m-TMSI": [3546890852, 32], "mmec": [48, 8]}]}]}]], "type": "PCCH-Message", "rrc_release": 10}
{"rrc_version": 113, "raw": "41030e8870e3e028f04743e9040d438f390800000000", "timestamp": 1535703290.361008, "pci": 357, "earfcn": 3050, "message": ["c1", ["paging", {"pagingRecordList": [{"cn-Domain": "ps", "ue-Identity": ["s-TMSI", {"m-TMSI": [3901165118, 32], "mmec": [48, 8]}]}, {"cn-Domain": "ps", "ue-Identity": ["s-TMSI", {"m-TMSI": [4031202281, 32], "mmec": [40, 8]}]}, {"cn-Domain": "cs", "ue-Identity": ["s-TMSI", {"m-TMSI": [3560502160, 32], "mmec": [64, 8]}]}]}]], "type": "PCCH-Message", "rrc_release": 10}
```

Each line contains one parsed message as JSON, with his hexadecimal representation.

This can be piped to jq for pretty printing, post-processing etc.:

```./diag-logger.py | jq .
{
  "timestamp": 1535703389.80531,
  "message": "Diag-Logger, DIAG Protocol Python Logger (c) Yan Grunenberger, 2018",
  "type": "debug"
}
{
  "rrc_version": 113,
  "raw": "40030dc0da5cc00000",
  "timestamp": 1535703391.481539,
  "pci": 357,
  "earfcn": 3050,
  "message": [
    "c1",
    [
      "paging",
      {
        "pagingRecordList": [
          {
            "cn-Domain": "ps",
            "ue-Identity": [
              "s-TMSI",
              {
                "m-TMSI": [
                  3691881932,
                  32
                ],
                "mmec": [
                  48,
                  8
                ]
              }
            ]
          }
        ]
      }
    ]
  ],
  "type": "PCCH-Message",
  "rrc_release": 10
}
```
