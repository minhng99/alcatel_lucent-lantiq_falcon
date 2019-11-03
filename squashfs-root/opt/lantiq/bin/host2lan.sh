#!/bin/sh

omci_simulate /opt/lantiq/bin/config/onu_setup_no_vlan.txt

# gem port ctp, MEID 0x200
omci_pipe.sh mr 00 01 44 0a 01 0c 02 00 02 00 80 00 02 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# gem port itp, MEID 0x200, bridge MEID 0x402
omci_pipe.sh mr 00 02 44 0a 01 0a 02 00 02 00 01 04 02 00 00 01 7d 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# bridge port, MEID 0x601, using magic bridge port number 0x88, bridge MEID 0x402
omci_pipe.sh mr 00 03 44 0a 00 2f 06 01 04 02 88 05 02 00 00 00 00 01 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
