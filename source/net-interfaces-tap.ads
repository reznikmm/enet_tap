--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with GNAT.OS_Lib;

package Net.Interfaces.Tap is

   type Tap_Ifnet is new Ifnet_Type with private;

   procedure Create (Self : in out Tap_Ifnet'Class);

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
