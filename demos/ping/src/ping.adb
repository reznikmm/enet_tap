--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Ada.Text_IO;
with Ada.Real_Time;

with Net.Buffers;
with Net.Protos.Arp;
with Net.Protos.Dispatchers;
with Net.Protos.Icmp;
with Net.Protos.IPv4;

with Network;

procedure Ping is

   procedure Send_Ping (Host : Net.Ip_Addr; Seq : in out Net.Uint16);
   --  Send ICMP Echo Request to given Host and Seq. Increment Seq.

   ---------------
   -- Send_Ping --
   ---------------

   procedure Send_Ping (Host : Net.Ip_Addr; Seq : in out Net.Uint16) is
      Packet : Net.Buffers.Buffer_Type;
      Status : Net.Error_Code;
   begin

      Net.Buffers.Allocate (Packet);

      if not Packet.Is_Null then
         Packet.Set_Length (64);
         Net.Protos.Icmp.Echo_Request
           (Ifnet     => Network.LAN.all,
            Target_Ip => Host,
            Packet    => Packet,
            Seq       => Seq,
            Ident     => 1234,
            Status    => Status);

         Seq := Net.Uint16'Succ (Seq);
      end if;
   end Send_Ping;

   Seq : Net.Uint16 := 0;

begin
   Ada.Text_IO.Put_Line ("Boot");
   Network.Initialize;

   declare
      Ignore : Net.Protos.Receive_Handler;
   begin
      Net.Protos.Dispatchers.Set_Handler
        (Proto    => Net.Protos.IPv4.P_ICMP,
         Handler  => Network.ICMP_Handler'Access,
         Previous => Ignore);
   end;

   loop
      declare
         use type Ada.Real_Time.Time;

         Now    : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;
         Ignore : Ada.Real_Time.Time;
      begin
         --  STM32.Board.Green_LED.Toggle; PA1 is used by LAN!!!
         Net.Protos.Arp.Timeout (Network.LAN.all);

         Send_Ping (Network.LAN.Gateway, Seq);

         delay until Now + Ada.Real_Time.Seconds (1);
      end;
   end loop;
end Ping;
