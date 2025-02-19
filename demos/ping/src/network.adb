--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Ada.Command_Line;
with Ada.Text_IO;
with Ada.Streams;

with Net.Headers;
with Net.Protos.Icmp;
with Net.Utils;
with Net.Generic_Receiver;

package body Network is

   package LAN_Receiver is new Net.Generic_Receiver
     (Net.Interfaces.Ifnet_Type'Class (MAC));

   Buffer_Memory : Ada.Streams.Stream_Element_Array (1 .. 1_024_000);

   procedure ICMP_Handler
     (Ifnet  : in out Net.Interfaces.Ifnet_Type'Class;
      Packet : in out Net.Buffers.Buffer_Type)
   is
      use type Net.Uint8;
      IP : constant Net.Headers.IP_Header_Access := Packet.IP;
      ICMP : constant Net.Headers.ICMP_Header_Access := Packet.ICMP;
   begin
      if ICMP.Icmp_Type = Net.Headers.ICMP_ECHO_REPLY then
         Ada.Text_IO.Put (Packet.Get_Length'Image);
         Ada.Text_IO.Put (" bytes from ");
         Ada.Text_IO.Put (Net.Utils.To_String (IP.Ip_Src));
         Ada.Text_IO.Put (" seq=");
         Ada.Text_IO.Put (Net.Headers.To_Host (ICMP.Icmp_Seq)'Image);
         Ada.Text_IO.New_Line;
      else
         Net.Protos.Icmp.Receive (Ifnet, Packet);
      end if;
   end ICMP_Handler;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      Argument : constant String :=
        (if Ada.Command_Line.Argument_Count = 0 then "tap0"
         else Ada.Command_Line.Argument (1));
   begin
      MAC.Create (Tap => Argument);

      Net.Buffers.Add_Region
        (Addr => Buffer_Memory'Address,
         Size => Buffer_Memory'Length);

      LAN_Receiver.Start;
      DHCP.Initialize (MAC'Access);
   end Initialize;

end Network;
