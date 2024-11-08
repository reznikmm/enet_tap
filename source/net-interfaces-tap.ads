--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with GNAT.OS_Lib;

with A0B.Callbacks;

package Net.Interfaces.Tap is

   type Tap_Ifnet is new Ifnet_Type with private;

   procedure Create
     (Self : in out Tap_Ifnet'Class;
      Tap  : String := "tap0");

   procedure Set_Send_Callback
     (Ifnet : in out Tap_Ifnet'Class;
      Done  : A0B.Callbacks.Callback);
   --  Assign the callback to be emited on a completion of each package sending

private

   type Tap_Ifnet is new Ifnet_Type with record
      FD : GNAT.OS_Lib.File_Descriptor := 0;
   end record;

   procedure Initialize (Self : in out Tap_Ifnet);

   procedure Send
     (Self   : in out Tap_Ifnet;
      Packet : in out Net.Buffers.Buffer_Type);

   procedure Receive
     (Self   : in out Tap_Ifnet;
      Packet : in out Net.Buffers.Buffer_Type);

end Net.Interfaces.Tap;
