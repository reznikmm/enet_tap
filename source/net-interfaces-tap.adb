--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

--  with Interfaces.C;
with Net.Headers;
with Net.Protos;
with Net.Protos.IPv4;

package body Net.Interfaces.Tap is

   type Uint16_Array is array (Positive range <>) of Uint16;

   function Get_Ip_Sum (Raw : Uint16_Array) return Uint16;

   ------------
   -- Create --
   ------------

   procedure Create (Self : in out Tap_Ifnet'Class) is
      --  use Standard.Interfaces;

      function create_tap
        (FD : in out GNAT.OS_Lib.File_Descriptor) return Integer
          with Import, Convention => C;

      Error : constant Integer := create_tap (Self.FD);
   begin
      if Error < 0 then
         raise Program_Error
           with "Can't open tap: " & GNAT.OS_Lib.Errno_Message;
      end if;
      null;
   end Create;

   ----------------
   -- Get_Ip_Sum --
   ----------------

   function Get_Ip_Sum (Raw : Uint16_Array) return Uint16 is
      Sum : Uint32 := 0;
   begin
      for Item of Raw loop
         Sum := Sum + Uint32 (Item);
      end loop;

      while Sum >= 16#1_0000# loop
         Sum := Sum - 16#1_0000# + 1;
      end loop;

      return not Uint16 (Sum);
   end Get_Ip_Sum;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Self : in out Tap_Ifnet) is
   begin
      Self.Create;
   end Initialize;

   -------------
   -- Receive --
   -------------

   procedure Receive
     (Self   : in out Tap_Ifnet;
      Packet : in out Net.Buffers.Buffer_Type)
   is
      Addr  : constant System.Address := Packet.Get_Data_Address;
      Size  : constant Natural := Net.Buffers.Data_Type'Length;
      Count : constant Integer := GNAT.OS_Lib.Read (Self.FD, Addr, Size);
   begin
      if Count not in 0 .. Integer (Uint16'Last) then
         raise Program_Error
           with "Can't read: " & GNAT.OS_Lib.Errno_Message (Err => Count);
      end if;

      Packet.Set_Length (Uint16 (Count));
   end Receive;

   ----------
   -- Send --
   ----------

   procedure Send
     (Self   : in out Tap_Ifnet;
      Packet : in out Net.Buffers.Buffer_Type)
   is
      Addr   : constant System.Address := Packet.Get_Data_Address;
      Ether  : Net.Headers.Ether_Header renames Packet.Ethernet.all;
      Ip     : Net.Headers.IP_Header renames Packet.IP.all;
      Ip_Raw : Uint16_Array (1 .. 10) with Import, Address => Ip'Address;
      Size   : constant Natural := Natural (Packet.Get_Length);
      Count  : Integer;
   begin
      if Ether.Ether_Type = Headers.To_Network (Net.Protos.ETHERTYPE_IP) then
         --  IPv4 header checksum offload
         Ip.Ip_Sum := 0;
         Ip.Ip_Sum := Get_Ip_Sum (Ip_Raw);

         case Ip.Ip_P is
            when Net.Protos.IPv4.P_ICMP =>
               declare
                  Size     : constant Positive :=
                    Positive (Packet.Get_Data_Size (Net.Buffers.IP_PACKET)) / 2;

                  ICMP     : Net.Headers.ICMP_Header renames Packet.ICMP.all;

                  ICMP_Raw : Uint16_Array (1 .. Size)
                    with Import, Address => ICMP'Address;
               begin
                  Packet.ICMP.Icmp_Checksum := 0;
                  Packet.ICMP.Icmp_Checksum := Get_Ip_Sum (ICMP_Raw);
               end;

            when Net.Protos.IPv4.P_UDP =>
               Packet.UDP.Uh_Sum := 0;

            when others =>
               null;
         end case;
      end if;

      Count := GNAT.OS_Lib.Write (Self.FD, Addr, Size);

      if Count < 0 then
         raise Program_Error
           with "Can't write: " & GNAT.OS_Lib.Errno_Message (Err => Count);
      end if;

      Packet.Release;
   end Send;

end Net.Interfaces.Tap;
