import fcntl
import os
 
import ctypes
import struct
 
from if_tun import IfReq, TUNSETIFF, IFF_TAP, IFF_NO_PI
 
def tun_create(devname, flags):
	fd = -1
	if not devname:
		return -1
	fd = os.open("/dev/net/tun", os.O_RDWR)
	if fd < 0:
		print("open /dev/net/tun err!")
		return fd
	r=IfReq()
	ctypes.memset(ctypes.byref(r), 0, ctypes.sizeof(r))
	r.ifr_ifru.ifru_flags |= flags
	r.ifr_ifrn.ifrn_name = devname.encode('utf-8')
	try:
		err = fcntl.ioctl(fd, TUNSETIFF, r)
	except Exception as e:
		print("err:",e)
		os.close(fd)
		return -1
	return fd

class TAP:
  MAXSIZE=4096
  def __init__(self, name, flags):
    self.fd = tun_create(name, flags)
    if self.fd < 0:
      raise OSError

  def write(self, data):
    #print('send data to tap:',data)
    num=0
    while num!=len(data): 
      num += os.write(self.fd, data)
      print('writed %s byte to tap'%num)

  def read(self, size):
    return os.read(self.fd, size)

  def fileno(self):
    return self.fd

  def up(self):
    print('UP')

  def close(self):
    os.close(self.fd)


if __name__ == "__main__":
	fd = tun_create("tap0", IFF_TAP)
	if fd < 0:
		raise OSError
 
	MAXSIZE=4096
	while(True):
		buf = os.read(fd,MAXSIZE)
		if not buf:
			break
                print("read size:%d" % len(buf))

