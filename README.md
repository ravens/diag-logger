# diag-logger
DIAG protocol logger for QC chipsets in Python.

This is a PoC for recovering events at the RRC/NAS level from a phone connected to a test eNB, logging them for post-processing. 

At the moment the script is able to activate the logging on a rooted phone (nexus 5) and is able to parse a very small subset of LTE frames - basically MIB and some RRC messages (which is what I need at the moment). NAS messages would be probably great.

Some ideas/todos : 
* add a websocket to pump info
* fix the parsing on recent phone (like nexus 5x)

## related projects

* [Osmocom wiki](https://osmocom.org/projects/quectel-modems/wiki/Diag) : a wiki page describing the protocol. 
* [Snoopsnitch](https://opensource.srlabs.de/projects/snoopsnitch) : an opensource project focused on collecting data on existing network by performing passive and active tests and recovering the event through the DIAG protocol on a rooted Android phone.
* [diag-parser](https://github.com/moiji-mobile/diag-parser) : an opensource project focused on reading data from a QC embedded modem and converting 2G,3G and LTE radio messages to GSMTAP format to make them parseable by Wireshark.
* [DiagLibrary](https://github.com/sanjaywave/DiagLibrary) : a JNI library that implement a DIAG protocol parser under C code to be used under Android or Linux.
* [USB-device-fuzzing](https://github.com/ollseg/usb-device-fuzzing) : an opensource, simple USB fuzzer using pyusb and scapy to implement the DIAG protocol.
* [Pycrate](https://github.com/ANSSI-FR/pycrate/) : the successor of the libmich library that is used to encode and decode data structures, including ASN.1 used in cellular protocol.

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
git clone https://github.com/ANSSI-FR/pycrate.git && cd pycrate && python setup.py install
```

I am using pycrate to parse ASN1 frames, and scapy to decode the packets from the usb bus (exactly like the USB fuzzing project mentionned before).

## how to run

Edit your USB device vendor and product ID within the script (right now it expects a Nexus 5)
Then to execute :
```
./diag-logger.py
```

The typical output should look like :
```
1535579212.08 PCI 39 EARFCN 1849 MasterInformationBlock
1535579212.66 PCI 445 EARFCN 1849 MasterInformationBlock
1535579225.54 PCI 75 EARFCN 6200 BCCH-DL-SCH-Message {u'message': (u'c1', (u'systemInformationBlockType1', {u'systemInfoValueTag': 22, u'si-WindowLength': u'ms10', u'nonCriticalExtension': {u'nonCriticalExtension': {u'cellSelectionInfo-v920': {u'q-QualMin-r9': -34}}}, u'freqBandIndicator': 20, u'cellAccessRelatedInfo': {u'csg-Indication': False, u'plmn-IdentityList': [{u'cellReservedForOperatorUse': u'notReserved', u'plmn-Identity': {u'mnc': [0, 3], u'mcc': [2, 1, 4]}}], u'intraFreqReselection': u'allowed', u'cellBarred': u'notBarred', u'cellIdentity': (909076, 28), u'trackingAreaCode': (1350, 16)}, u'p-Max': 23, u'schedulingInfoList': [{u'si-Periodicity': u'rf8', u'sib-MappingInfo': [u'sibType3']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType4']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType5']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType6']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType7']}], u'cellSelectionInfo': {u'q-RxLevMin': -62}}))} 68485007054600ddf1482354c8020610b089846c247650000000000050f97e100015001500c1b00000d164bf2be300014b00381838030232b5937e100046004600c0b000000c65bf2be300070a71004b0038180034020c0000002900008309f2b7ec50f81b014b000c000100020d3b8755781d00ca00c02bdd800c38800f0044a87688d5e4
1535579243.13 PCI 357 EARFCN 3050 BCCH-DL-SCH-Message {u'message': (u'c1', (u'systemInformationBlockType1', {u'systemInfoValueTag': 18, u'si-WindowLength': u'ms10', u'nonCriticalExtension': {u'nonCriticalExtension': {u'cellSelectionInfo-v920': {u'q-QualMin-r9': -34}}}, u'freqBandIndicator': 7, u'cellAccessRelatedInfo': {u'csg-Indication': False, u'plmn-IdentityList': [{u'cellReservedForOperatorUse': u'notReserved', u'plmn-Identity': {u'mnc': [0, 3], u'mcc': [2, 1, 4]}}], u'intraFreqReselection': u'allowed', u'cellBarred': u'notBarred', u'cellIdentity': (85248, 28), u'trackingAreaCode': (1350, 16)}, u'p-Max': 23, u'schedulingInfoList': [{u'si-Periodicity': u'rf8', u'sib-MappingInfo': [u'sibType3']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType4']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType5']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType6']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType7']}], u'cellSelectionInfo': {u'q-RxLevMin': -64}}))} 6848500705460014d0081b5188020610b089846c2472500000000000614e7e100015001500c1b07102cd9bbf2be300016501ea0bac02026443537e100046004600c0b07402e79bbf2be300070a71006501ea0b002b020c0000002900008309f2b7ec54a21b014b000c000100220d14e755781d00ca00c02bdd800c38800f0044a89e86d6e4
1535579253.35 PCI 39 EARFCN 1849 BCCH-DL-SCH-Message {u'message': (u'c1', (u'systemInformationBlockType1', {u'systemInfoValueTag': 24, u'si-WindowLength': u'ms10', u'nonCriticalExtension': {u'nonCriticalExtension': {u'cellSelectionInfo-v920': {u'q-QualMin-r9': -34}}}, u'freqBandIndicator': 3, u'cellAccessRelatedInfo': {u'csg-Indication': False, u'plmn-IdentityList': [{u'cellReservedForOperatorUse': u'notReserved', u'plmn-Identity': {u'mnc': [0, 3], u'mcc': [2, 1, 4]}}], u'intraFreqReselection': u'allowed', u'cellBarred': u'notBarred', u'cellIdentity': (85258, 28), u'trackingAreaCode': (1350, 16)}, u'p-Max': 23, u'schedulingInfoList': [{u'si-Periodicity': u'rf8', u'sib-MappingInfo': [u'sibType3']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType4']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType5']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType6']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType7']}], u'cellSelectionInfo': {u'q-RxLevMin': -64}}))} 6848500705460014d0a81b5088020610b089846c2478500000000000b5d37e100046004600c0b06f02bbbbbf2be300070a7100270039070000020c0000002900008309f2b7ec50801b014b000c000100220d3b8755781d00ca00c02bdd800c38800f0044a89e86d6e4780a7e100015001500c1b06f02bdbbbf2be3000127003907a8020264
1535579263.57 PCI 75 EARFCN 6200 MasterInformationBlock
```

In that case, my Nexus 5 is scanning various networks for a suitable cell, on one of the spanish cell networks.

Note that right now with my nexus5x the PDU I am looging are different and not recognized by the script (which classifies them as Unknown and dump the hexadecimal value). 

The frame format on the nexus5x is using a more advanced release (ota_version==9 instead of ota_version==7), which might affect the OTA frame type, hence the parsing. 

Probably bruteforcing the frame using an online RRC LTE decoder (and some intuition that the paging are the most typical message on an idle phone) will give some hints on the QCDM protocol differences, and adapt the script to the version level using ConditionalField option of Scapy.

