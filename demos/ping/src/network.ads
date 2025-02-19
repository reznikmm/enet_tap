--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Net.Buffers;
with Net.DHCP;
with Net.Interfaces;
with Net.Interfaces.Tap;

package Network is

   procedure Initialize;

   function LAN return not null access Net.Interfaces.Ifnet_Type'Class;
   --  Network interface

   DHCP : Net.DHCP.Client;

   procedure ICMP_Handler
     (Ifnet  : in out Net.Interfaces.Ifnet_Type'Class;
      Packet : in out Net.Buffers.Buffer_Type);
   --  Custom ICMP handler to pring ICMP echo responses

private

   MAC : aliased Net.Interfaces.Tap.Tap_Ifnet;

   function LAN return not null access Net.Interfaces.Ifnet_Type'Class is
     (MAC'Access);

end Network;
