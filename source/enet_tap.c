// SPDX-FileCopyrightText: 2024 2024 Max Reznik <reznikmm@gmail.com>
//
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#include <net/if.h>
#include <linux/if_tun.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
/*#include <sys/types.h>*/
/*#include <sys/stat.h>*/
#include <fcntl.h>

int
create_tap (int *fd)
{
  int err;
  struct ifreq ifr;

  if ((*fd = open ("/dev/net/tun", O_RDWR)) < 0)
    return *fd;

  memset(&ifr, 0, sizeof(ifr));
  ifr.ifr_flags = IFF_TAP | IFF_NO_PI;

  if ((err = ioctl (*fd, TUNSETIFF, (void *)&ifr)) < 0)
    {
      close (*fd);
      return err;
    }

  return 0;
}
