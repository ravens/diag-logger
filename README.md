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
{'timestamp': 1535665551.568411, 'earfcn': 1849, 'pci': 39, 'type': 'MasterInformationBlock'}

{'rrc_version': 113, 'raw': '008309f2b7ec50801b014b000c000100220d3b8755781d00ca00c02bdd800c38800f0044a89e86d6e4070b7e100039003900c0b00000c72ddd2fe300070a710027003907051002020000001c006848500705460014d0a81b5088020610b089846c247c500000000000b7a77e10002a002a00c0b00000cb2ddd2fe300070a710027003907101002100000000d0000091028a05346f24dec4a08008bcc7e100015001500c1b00000d02ddd2fe30001270039070001026471c87e100042004200c0b00000db2ddd2fe300070a7100270039073010024000000025000011112e3d9c03ca334e04380794669a78700f28cd2b8083029a1a50c10605342000000000366a7e100020002000c0b00000e32ddd2fe300070a710127003907000006000000000300300120221e7e10001f001f00c0b00000e32ddd2fe300070a71012700390700000800000000020028008d277e100046004600c0b00000e42ddd2fe300070a71002700390740d0028000000029000014c079e31e87a3e97a7ea7abeb7afec7b3ed7b7ee7bbef7bff07c3f17c7f27fdfeff92ff08420000dd277e100025002500c0b00000f72ddd2fe300070a71012700390700000600000000080038280498818084c082327e1000eb00eb00c0b00000f82ddd2fe300070a71012700390700000800000000ce003803035c5a00005001040c1c9858bf93ffc5fc9ffe2fe4fff17f27ff8bf93ffc5fc9ffd743ff20220a008c8538653a54913f02c40000000001808240001ba8caab541a955aa22920c112000600054384271cfbde899ebb65ca138e7def44cf5db2f509c73ef7a267aed97684e39f7bd133d76cb73d0131c410a438f5e7a1a267aed96c00c80e80d80dc152980000b492d691006cec2a042891a3d3c6a042891a3d3d6a042891a3d3cea042891a3d3d2a042891a3d3a15021448d1e9ec020f33035758a6601404ef651021e242ca0cea37e1000f800f800c0b00000172edd2fe300070a71012700390700000600000000db00201615880004039cdc400a14114a84a070f78c26f5a100290285970811925a1b840000401668500809d27499ae5d6075be3311d6b6afefa850287806a74c54350be556d164e15720174172d7dfa91087dd329cd7d738d8c3b7c3ee819201535c3c75e72a010cdff981ba515faf5f8dda4e7b1a003b0d0dca20fcf2ac65d8562f1342faa760bad2581f2ee8de13c6781e23e6cd5b78d577bad363714364dd741b414d8ca97261b61604b6a91335291b035a4dc38af14f9566b70016c3aca558424c49d8365627a68703ff738107d44dc07aee71439118b77491bc8728ad7e10001f001f00c0b00000182edd2fe300070a7101270039070000080000000002001000d56e7e1000ad00ad00eab00000182edd2fe3000109050027499ae5d6075be3311d6b6afefa850287806a74c54350be556d164e15720174172d7dfa91087dd329cd7d738d8c3b7c3ee819201535c3c75e72a010cdff981ba515faf5f8dda4e7b1a003b0d0dca20fcf2ac65d8562f1342faa760bad2581f2ee8de13c6781e23e6cd5b78d577bad363714364dd741b414d8ca97261b61604b6a91335291b035a4dc38af14f9566b70016c3aca558424c49d8365627a56e47e1000a700a700ecb00000182edd2fe300010905000742024f060012f430054600745204c101081f0b6f72616e6765776f726c64066d6e63303033066d636332313404677072730501645c0b5b5d010030101b931f7396fefe744bffff00fa00fa003209833401085e04fefefafa272680802110030000108106553ee5878306553ee588000d04553ee587000d04553ee58800050102500bf612f430800050ca010cfc1312f430047e64010110b37e10009a009a00e2b00000182edd2fe300010905005204c101081f0b6f72616e6765776f726c64066d6e63303033066d636332313404677072730501645c0b5b5d010030101b931f7396fefe744bffff00fa00fa003209833401085e04fefefafa272680802110030000108106553ee5878306553ee588000d04553ee587000d04553ee58800050102500bf612f430800050ca010cfc1312f430047e6401014ace7e100018001800ebb000001a2edd2fe30001090500000000000000000081fc7e10001d001d00edb000001a2edd2fe30001090500074300035200c2000000000000c0cf7e10001d001d00ebb000001e2edd2fe30001090500278c6b0f9f21a55ed95f0d1a9165b47e10002d002d00c0b000001f2edd2fe300070a7102270039070000080000000010004801a4f18d61f3e434abdb2be1a3522095417e100047004700c0b000004b2edd2fe300070a710227003907000006000000002a000801393d41c49aa0415adb87b0552e1936f84802fd249e014a2c212387e424b1e4fa518c6b1b738f75782df97e100037003700eab000004b2edd2fe3000109050027a8389354082b5b70f60aa5c326df09005fa493c02945842470fc84963c9f4a318d636e71eeafc95d7e100031003100ecb000004b2edd2fe3000109050007614307864f79d87d2e034507864f79d87d2e0346804781800312541580490101', 'timestamp': 1535665551.832757, 'pci': 39, 'earfcn': 1849, 'message': (u'c1', (u'systemInformation', {u'criticalExtensions': (u'systemInformation-r8', {u'sib-TypeAndInfo': [(u'sib2', {u'ac-BarringInfo': {u'ac-BarringForEmergency': False}, u'ue-TimersAndConstants': {u't310': u'ms2000', u't311': u'ms10000', u't301': u'ms400', u't300': u'ms1000', u'n310': u'n20', u'n311': u'n1'}, u'ac-BarringSkipForSMS-r12': u'true', u'radioResourceConfigCommon': {u'uplinkPowerControlCommon': {u'p0-NominalPUCCH': -120, u'alpha': u'al07', u'p0-NominalPUSCH': -67, u'deltaPreambleMsg3': 6, u'deltaFList-PUCCH': {u'deltaF-PUCCH-Format2a': u'deltaF0', u'deltaF-PUCCH-Format2b': u'deltaF0', u'deltaF-PUCCH-Format2': u'deltaF0', u'deltaF-PUCCH-Format1b': u'deltaF3', u'deltaF-PUCCH-Format1': u'deltaF0'}}, u'pdsch-ConfigCommon': {u'referenceSignalPower': 15, u'p-b': 0}, u'soundingRS-UL-ConfigCommon': (u'setup', {u'ackNackSRS-SimultaneousTransmission': True, u'srs-BandwidthConfig': u'bw0', u'srs-SubframeConfig': u'sc6'}), u'bcch-Config': {u'modificationPeriodCoeff': u'n2'}, u'pusch-ConfigCommon': {u'pusch-ConfigBasic': {u'pusch-HoppingOffset': 0, u'n-SB': 1, u'enable64QAM': True, u'hoppingMode': u'interSubFrame'}, u'ul-ReferenceSignalsPUSCH': {u'cyclicShift': 0, u'groupHoppingEnabled': True, u'groupAssignmentPUSCH': 0, u'sequenceHoppingEnabled': False}}, u'pcch-Config': {u'nB': u'oneT', u'defaultPagingCycle': u'rf64'}, u'ul-CyclicPrefixLength': u'len1', u'prach-Config': {u'rootSequenceIndex': 64, u'prach-ConfigInfo': {u'prach-FreqOffset': 2, u'prach-ConfigIndex': 3, u'highSpeedFlag': False, u'zeroCorrelationZoneConfig': 12}}, u'pucch-ConfigCommon': {u'deltaPUCCH-Shift': u'ds1', u'nCS-AN': 0, u'nRB-CQI': 1, u'n1PUCCH-AN': 8}, u'uplinkPowerControlCommon-v1020': {u'deltaF-PUCCH-Format3-r10': u'deltaF0', u'deltaF-PUCCH-Format1bCS-r10': u'deltaF2'}, u'pusch-ConfigCommon-v1270': {u'enable64QAM-v1270': u'true'}, u'rach-ConfigCommon': {u'maxHARQ-Msg3Tx': 4, u'ra-SupervisionInfo': {u'preambleTransMax': u'n10', u'mac-ContentionResolutionTimer': u'sf64', u'ra-ResponseWindowSize': u'sf10'}, u'preambleInfo': {u'numberOfRA-Preambles': u'n64'}, u'powerRampingParameters': {u'powerRampingStep': u'dB4', u'preambleInitialReceivedTargetPower': u'dBm-110'}}}, u'freqInfo': {u'additionalSpectrumEmission': 1}, u'ac-BarringSkipForMMTELVideo-r12': u'true', u'ac-BarringSkipForMMTELVoice-r12': u'true', u'timeAlignmentTimerCommon': u'sf1920'}), (u'sib3', {u'intraFreqCellReselectionInfo': {u'presenceAntennaPort1': True, u'p-Max': 23, u't-ReselectionEUTRA': 2, u'allowedMeasBandwidth': u'mbw100', u'neighCellConfig': (2, 2), u'q-RxLevMin': -64}, u'cellReselectionInfoCommon': {u'q-Hyst': u'dB4'}, u'cellReselectionServingFreqInfo': {u'threshServingLow': 4, u's-NonIntraSearch': 10, u'cellReselectionPriority': 7}})]})})), 'type': 'BCCH-DL-SCH-Message', 'rrc_release': 10}

{'rrc_version': 113, 'raw': '40038e87ad20200000', 'timestamp': 1535665553.170308, 'pci': 39, 'earfcn': 1849, 'message': (u'c1', (u'paging', {u'pagingRecordList': [{u'cn-Domain': u'ps', u'ue-Identity': (u's-TMSI', {u'm-TMSI': (3900363266, 32), u'mmec': (56, 8)})}]})), 'type': 'PCCH-Message', 'rrc_release': 10}

{'rrc_version': 113, 'raw': '40038e87ad20200000', 'timestamp': 1535665555.089629, 'pci': 39, 'earfcn': 1849, 'message': (u'c1', (u'paging', {u'pagingRecordList': [{u'cn-Domain': u'ps', u'ue-Identity': (u's-TMSI', {u'm-TMSI': (3900363266, 32), u'mmec': (56, 8)})}]})), 'type': 'PCCH-Message', 'rrc_release': 10}

{'rrc_version': 113, 'raw': '40058d9f0449500000', 'timestamp': 1535665558.2905, 'pci': 39, 'earfcn': 1849, 'message': (u'c1', (u'paging', {u'pagingRecordList': [{u'cn-Domain': u'ps', u'ue-Identity': (u's-TMSI', {u'm-TMSI': (3656402069, 32), u'mmec': (88, 8)})}]})), 'type': 'PCCH-Message', 'rrc_release': 10}

{'rrc_version': 113, 'raw': '2812e282fab839cf1838a1e78c7a1e8fa5e9fa9eafadebfb1ecfb5edfb9eefbdeffc1f0fc5f1fc9ff7fbfe222e3dd38129a7984efd7e100026002600c0b000002752dd2fe300070a71002700390759d80400000000090040048dc9c432300000a2737e100025002500c2b000002a52dd2fe3000227003907894d64640a4d0100460503000000d60002030000', 'timestamp': 1535665563.407009, 'pci': 39, 'earfcn': 1849, 'message': (u'c1', (u'rrcConnectionRelease', {u'rrc-TransactionIdentifier': 0, u'criticalExtensions': (u'c1', (u'rrcConnectionRelease-r8', {u'idleModeMobilityControlInfo': {u't320': u'min180', u'freqPriorityListGERAN': [{u'carrierFreqs': {u'bandIndicator': u'dcs1800', u'startingARFCN': 975, u'followingARFCNs': (u'explicitListOfARFCNs', [976, 977, 978, 979, 980, 981, 982, 983, 984, 985, 986, 987, 988, 989, 990, 991, 992, 993, 994, 995, 996, 1022, 1021, 1020])}, u'cellReselectionPriority': 2}], u'freqPriorityListEUTRA': [{u'carrierFreq': 3050, u'cellReselectionPriority': 7}, {u'carrierFreq': 1849, u'cellReselectionPriority': 7}, {u'carrierFreq': 6200, u'cellReselectionPriority': 5}], u'freqPriorityListUTRA-FDD': [{u'carrierFreq': 2959, u'cellReselectionPriority': 3}, {u'carrierFreq': 10688, u'cellReselectionPriority': 4}, {u'carrierFreq': 10663, u'cellReselectionPriority': 4}]}, u'releaseCause': u'other'}))})), 'type': 'DL-DCCH-Message', 'rrc_release': 10}

{'rrc_version': 113, 'raw': '000c9705f50daa29afcd1b2a94b05c307036a8a67b44496acdd0403459487f930000000000', 'timestamp': 1535665564.010988, 'pci': 39, 'earfcn': 1849, 'message': (u'c1', (u'systemInformation', {u'criticalExtensions': (u'systemInformation-r8', {u'sib-TypeAndInfo': [(u'sib5', {u'interFreqCarrierFreqList': [{u'threshX-Low': 6, u'presenceAntennaPort1': True, u'interFreqNeighCellList': [{u'physCellId': 357, u'q-OffsetCell': u'dB-5'}, {u'physCellId': 165, u'q-OffsetCell': u'dB1'}], u't-ReselectionEUTRA': 2, u'p-Max': 23, u'threshX-High': 5, u'allowedMeasBandwidth': u'mbw100', u'q-OffsetFreq': u'dB-2', u'neighCellConfig': (2, 2), u'q-RxLevMin': -64, u'dl-CarrierFreq': 3050, u'cellReselectionPriority': 7}, {u'threshX-Low': 6, u'presenceAntennaPort1': True, u'interFreqNeighCellList': [{u'physCellId': 75, u'q-OffsetCell': u'dB-5'}, {u'physCellId': 411, u'q-OffsetCell': u'dB5'}], u't-ReselectionEUTRA': 2, u'p-Max': 23, u'threshX-High': 5, u'allowedMeasBandwidth': u'mbw50', u'q-OffsetFreq': u'dB2', u'neighCellConfig': (2, 2), u'q-RxLevMin': -64, u'dl-CarrierFreq': 6200, u'cellReselectionPriority': 5}, {u'presenceAntennaPort1': True, u'threshX-High': 3, u'threshX-Low': 31, u't-ReselectionEUTRA': 2, u'allowedMeasBandwidth': u'mbw75', u'q-OffsetFreq': u'dB0', u'neighCellConfig': (2, 2), u'q-RxLevMin': -60, u'dl-CarrierFreq': 1675, u'cellReselectionPriority': 1}]})]})})), 'type': 'BCCH-DL-SCH-Message', 'rrc_release': 10}

{'rrc_version': 113, 'raw': '6848500705460014d0a81b5088020610b089846c247c500000000000dbb07e100015001500c1b00000d055dd2fe300012700390700020264', 'timestamp': 1535665564.636847, 'pci': 39, 'earfcn': 1849, 'message': (u'c1', (u'systemInformationBlockType1', {u'systemInfoValueTag': 28, u'si-WindowLength': u'ms10', u'nonCriticalExtension': {u'nonCriticalExtension': {u'cellSelectionInfo-v920': {u'q-QualMin-r9': -34}}}, u'freqBandIndicator': 3, u'cellAccessRelatedInfo': {u'csg-Indication': False, u'plmn-IdentityList': [{u'cellReservedForOperatorUse': u'notReserved', u'plmn-Identity': {u'mnc': [0, 3], u'mcc': [2, 1, 4]}}], u'intraFreqReselection': u'allowed', u'cellBarred': u'notBarred', u'cellIdentity': (85258, 28), u'trackingAreaCode': (1350, 16)}, u'p-Max': 23, u'schedulingInfoList': [{u'si-Periodicity': u'rf8', u'sib-MappingInfo': [u'sibType3']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType4']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType5']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType6']}, {u'si-Periodicity': u'rf64', u'sib-MappingInfo': [u'sibType7']}], u'cellSelectionInfo': {u'q-RxLevMin': -64}})), 'type': 'BCCH-DL-SCH-Message', 'rrc_release': 10}
```

Each line contains one parsed message, with his hexadecimal representation.