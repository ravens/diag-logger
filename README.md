# diag-logger
DIAG protocol logger for QC chipsets in Python.

This is a PoC for recovering events at the RRC/NAS level from a phone connected to a test eNB, logging them for post-processing. 

At the moment the script is able to activate the logging on a rooted phone (nexus 5/nexus 5x) and is able to parse a very small subset of LTE frames - basically MIB and some RRC messages (which is what I need at the moment). NAS messages would be probably a great addition.

Some ideas/todos : 
* add a websocket to pump info
* fix concatenated messages parsing by check the length advertized in the ota header. At the moment only the first one is parsed.   
* dump the binary into a PCAP using DLT like the [srsLTE](https://github.com/srsLTE/srsLTE/blob/4762483396fdaff86b16988a0e2527334fc57136/lib/include/srslte/common/pcap.h) folks, or use GSMTAP like diag-parser.

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

The typical output should look like (using my nexus5 on 214-03) :
```
1535579212.08 PCI 39 EARFCN 1849 MasterInformationBlock
1535579212.66 PCI 445 EARFCN 1849 MasterInformationBlock
1535579225.54 PCI 75 EARFCN 6200 BCCH-DL-SCH-Message {u'message': (u'c1', (u'systemInformationBlockType1', {u'systemInfoValueTag': 22, u'si-WindowLength': u'ms10', u'nonCriticalExtension': {u'nonCriticalExtension': {u'cellSelectionInfo-v920': {u'q-QualMin-r9': -34}}}, u'freqBandIndicator': 20, u'cellAccessRelatedInfo': {u'csg-Indication': False, u'plmn-IdentityList': [{u'cellReservedForOperatorUse': u'notReserved', u'plmn-Identity': {u'mnc': [0, 3], u'mcc': [2, 1, 4]}}], u'intraFreqReselection': u'allowed', u'cellBarred': u'notBarred', u'cellIdentity': (909076, 28), u'trackingAreaCode': (1350, 16)}, u'p-Max': 23, u'schedulingInfoList': [{u'si-Periodicity': u'rf8', u'sib-MappingInfo': [u'sibType3']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType4']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType5']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType6']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType7']}], u'cellSelectionInfo': {u'q-RxLevMin': -62}}))} 68485007054600ddf1482354c8020610b089846c247650000000000050f97e100015001500c1b00000d164bf2be300014b00381838030232b5937e100046004600c0b000000c65bf2be300070a71004b0038180034020c0000002900008309f2b7ec50f81b014b000c000100020d3b8755781d00ca00c02bdd800c38800f0044a87688d5e4
1535579243.13 PCI 357 EARFCN 3050 BCCH-DL-SCH-Message {u'message': (u'c1', (u'systemInformationBlockType1', {u'systemInfoValueTag': 18, u'si-WindowLength': u'ms10', u'nonCriticalExtension': {u'nonCriticalExtension': {u'cellSelectionInfo-v920': {u'q-QualMin-r9': -34}}}, u'freqBandIndicator': 7, u'cellAccessRelatedInfo': {u'csg-Indication': False, u'plmn-IdentityList': [{u'cellReservedForOperatorUse': u'notReserved', u'plmn-Identity': {u'mnc': [0, 3], u'mcc': [2, 1, 4]}}], u'intraFreqReselection': u'allowed', u'cellBarred': u'notBarred', u'cellIdentity': (85248, 28), u'trackingAreaCode': (1350, 16)}, u'p-Max': 23, u'schedulingInfoList': [{u'si-Periodicity': u'rf8', u'sib-MappingInfo': [u'sibType3']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType4']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType5']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType6']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType7']}], u'cellSelectionInfo': {u'q-RxLevMin': -64}}))} 6848500705460014d0081b5188020610b089846c2472500000000000614e7e100015001500c1b07102cd9bbf2be300016501ea0bac02026443537e100046004600c0b07402e79bbf2be300070a71006501ea0b002b020c0000002900008309f2b7ec54a21b014b000c000100220d14e755781d00ca00c02bdd800c38800f0044a89e86d6e4
1535579253.35 PCI 39 EARFCN 1849 BCCH-DL-SCH-Message {u'message': (u'c1', (u'systemInformationBlockType1', {u'systemInfoValueTag': 24, u'si-WindowLength': u'ms10', u'nonCriticalExtension': {u'nonCriticalExtension': {u'cellSelectionInfo-v920': {u'q-QualMin-r9': -34}}}, u'freqBandIndicator': 3, u'cellAccessRelatedInfo': {u'csg-Indication': False, u'plmn-IdentityList': [{u'cellReservedForOperatorUse': u'notReserved', u'plmn-Identity': {u'mnc': [0, 3], u'mcc': [2, 1, 4]}}], u'intraFreqReselection': u'allowed', u'cellBarred': u'notBarred', u'cellIdentity': (85258, 28), u'trackingAreaCode': (1350, 16)}, u'p-Max': 23, u'schedulingInfoList': [{u'si-Periodicity': u'rf8', u'sib-MappingInfo': [u'sibType3']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType4']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType5']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType6']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType7']}], u'cellSelectionInfo': {u'q-RxLevMin': -64}}))} 6848500705460014d0a81b5088020610b089846c2478500000000000b5d37e100046004600c0b06f02bbbbbf2be300070a7100270039070000020c0000002900008309f2b7ec50801b014b000c000100220d3b8755781d00ca00c02bdd800c38800f0044a89e86d6e4780a7e100015001500c1b06f02bdbbbf2be3000127003907a8020264
1535579263.57 PCI 75 EARFCN 6200 MasterInformationBlock
```

Another output with the nexus 5x (on 214-07):
```
1535637819.29 PCI 21 EARFCN 2850 PCCH-Message {u'message': (u'c1', (u'paging', {u'pagingRecordList': [{u'cn-Domain': u'ps', u'ue-Identity': (u's-TMSI', {u'm-TMSI': (3431980877, 32), u'mmec': (144, 8)})}]}))} 40090cc8fdf4d00000
1535637825.19 PCI 32 EARFCN 6400 BCCH-DL-SCH-Message {u'message': (u'c1', (u'systemInformationBlockType1', {u'systemInfoValueTag': 7, u'si-WindowLength': u'ms10', u'freqBandIndicator': 20, u'cellAccessRelatedInfo': {u'csg-Indication': False, u'plmn-IdentityList': [{u'cellReservedForOperatorUse': u'notReserved', u'plmn-Identity': {u'mnc': [0, 7], u'mcc': [2, 1, 4]}}], u'intraFreqReselection': u'allowed', u'cellBarred': u'notBarred', u'cellIdentity': (71700255, 28), u'trackingAreaCode': (28620, 16)}, u'p-Max': 23, u'schedulingInfoList': [{u'si-Periodicity': u'rf8', u'sib-MappingInfo': [u'sibType3']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType4']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType5']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType6']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType7']}], u'cellSelectionInfo': {u'q-RxLevMin': -60}}))} 6048500f6fcc4460f1f82b54c8020610b089846c246786c67e100017001700c1b054a66ab78a2ee3000220000019000068020232e0717e100044004400c0b02f1d95b78a2ee300090b70002000001900000027090c000000250000804c95bf629b81580e60006000200101eea55781d00ca00c01bdc801c22462b456af2000ce7a7e100029002900c2b0e95ca3b78a2ee30003200000190000505f000032321f0f4604cc6f14000000d60002070001
1535637825.61 PCI 21 EARFCN 2850 MasterInformationBlock
1535637825.9 PCI 21 EARFCN 2850 BCCH-DL-SCH-Message {u'message': (u'c1', (u'systemInformation', {u'criticalExtensions': (u'systemInformation-r8', {u'sib-TypeAndInfo': [(u'sib5', {u'interFreqCarrierFreqList': [{u'threshX-Low': 3, u'presenceAntennaPort1': True, u't-ReselectionEUTRA': 2, u'p-Max': 23, u'threshX-High': 7, u'allowedMeasBandwidth': u'mbw100', u'q-OffsetFreq': u'dB0', u'neighCellConfig': (2, 2), u'q-RxLevMin': -62, u'dl-CarrierFreq': 1301, u'cellReselectionPriority': 6}, {u'presenceAntennaPort1': True, u'threshX-High': 3, u'threshX-Low': 7, u't-ReselectionEUTRA': 2, u'allowedMeasBandwidth': u'mbw75', u'q-OffsetFreq': u'dB0', u'neighCellConfig': (2, 2), u'q-RxLevMin': -60, u'dl-CarrierFreq': 1675, u'cellReselectionPriority': 0}]})]})}))} 000c54028a91aa38ef4201a2ca433c880000a0cf7e10003b003b00c0b04c77a9b98a2ee300090b70001500220b0000201409400000001c0000110d2f0e1c014a4352b238029486a3d47005290d4488400a51980098337e1000ac00ac00c0b0b21eb1b98a2ee300090b70001500220b0000301409800000008d000014c300230010060200a0300e04012050160601a0701e08022090260a02a0b02e0c0331ff1c4305e2c18062190661a06a1b06e1c0721d0761e07a1f07e20082210862208b1ff1c4340227014070240b0340f04413054170641b0741f08423094279547fc710d0a0b42b0b42f0c4330d4370e43b0f43f2c4b32d4b72e4bb2f4bf304c33147fc710c0000000000ee977e10004c004c00c0b08bbb05ba8a2ee300090b70011500220b0000d6140d000000002d000801513dd4b657e01ab8bb633b73c30190661568e02de3bfc7c440f374f24668aa1530b363d541d7ab90463fe85cc17e10003a003a00eab0898206ba8a2ee3000109050027ba96cafc0357176c676e7860320cc2ad1c05bc77f8f8881e6e9e48cd1542a6166c7aa83af57208c7fd5d3a7e100034003400ecb0898206ba8a2ee30001090500075202a8e950acfa637693a74b2f7c8fd380f8100d3920ab2cf780005411068a8edd24b5
```