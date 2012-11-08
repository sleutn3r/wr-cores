volatile unsigned int* leds = (unsigned int*)0x100400;
volatile unsigned int* singlepulse_delay = (unsigned int*)0x110000;
volatile unsigned int* singlepulse_duration = (unsigned int*)0x110004;
volatile unsigned int* singlepulse_control = (unsigned int*)0x110008;
volatile unsigned int* singlepulse_status = (unsigned int*)0x11000c;

volatile unsigned int* pattern_data = (unsigned int*)0x110400;
volatile unsigned int* pattern_period = (unsigned int*)0x110404;
volatile unsigned int* pattern_control = (unsigned int*)0x110408;
volatile unsigned int* pattern_status = (unsigned int*)0x11040c;

volatile unsigned int* BuTiSclock_lw = (unsigned int*)0x110500;
volatile unsigned int* BuTiSclock_hw = (unsigned int*)0x110504;
volatile unsigned int* BuTiSclock_control = (unsigned int*)0x110508;
volatile unsigned int* BuTiSclock_status = (unsigned int*)0x11050c;

volatile unsigned int* rs232_datasend = (unsigned int*)0x110600;
volatile unsigned int* rs232_dataread = (unsigned int*)0x110604;
volatile unsigned int* rs232_readdone = (unsigned int*)0x110608;
volatile unsigned int* rs232_status = (unsigned int*)0x11060c;
volatile unsigned int* rs232_control = (unsigned int*)0x110610;

volatile unsigned int* readtime_highword = (unsigned int*)0x110700;
volatile unsigned int* readtime_lowword = (unsigned int*)0x110704;
volatile unsigned int* readtime_errors = (unsigned int*)0x110708;
volatile unsigned int* readtime_corrections = (unsigned int*)0x11070c;
volatile unsigned int* readtime_control = (unsigned int*)0x110710;

void _read(void) {}
void isatty(void) {}
void _sbrk(void) {}
void _write(void) {}
void _close(void) {}
void _fstat(void) {}
void _lseek(void) {}


#define INT_DIGITS 19		/* enough for 64 bit integer */

char *itoa(int i)
{
  /* Room for INT_DIGITS digits, - and '\0' */
  static char buf[INT_DIGITS + 2];
  char *p = buf + INT_DIGITS + 1;	/* points to terminating '\0' */
  if (i >= 0) {
    do {
      *--p = '0' + (i % 10);
      i /= 10;
    } while (i != 0);
    return p;
  }
  else {			/* i < 0 */
    do {
      *--p = '0' - (i % 10);
      i /= 10;
    } while (i != 0);
    *--p = '-';
  }
  return p;
}


void _irq_entry(void) {
  /* Currently only triggered by DMA completion */
}

int writechar(char c) {// send character, return 0 on success
	int timeout=0;
	int i;
	while ((*pattern_status & 0x1)==1) { // wait till previous character has been sent
		asm("# noop"); /* no-op the compiler can't optimize away */
		if (timeout++>=20000) return -1;
	}
	*pattern_control = 2;
	*pattern_data = 1; // start bit
	for (i=0; i<8; i++) 
		if ((c >> i) & 1) *pattern_data = 0; else *pattern_data = 1;
	*pattern_data = 0; // stop bit
	*pattern_data = 0; // stop bit
	*pattern_control = 0;
	*pattern_control = 8; // soft trigger
	return 0;
}

int writechar_rs232module(char c) {// send character, return 0 on success
	int timeout=0;
	while ((*rs232_status & 0x1)==0) { // wait till previous character has been sent
		asm("# noop"); /* no-op the compiler can't optimize away */
		if (timeout++>=20000) return -1;
	}
	*rs232_datasend=c;
	return 0;
}

int writestring(char *s) {// send characters, return 0 on success
	int i=0;
	while (s[i]) { if (writechar(s[i++])) return -1; }
	return 0;
}

void printhex(unsigned int hw, unsigned int lw, unsigned int cw) {
	int i=0;
	char c;
	unsigned int n;
	if (cw & 0x02) { // error detected in serially sent timestamp
		c='X';
	} else if (cw & 0x04) { // error succesfully corrected in serially sent timestamp
		c='`';
	} else {
		c=' ';
	}
	if (writechar(c)) return;
	
	for (i=0; i<18; i++) {
		if (i<8) {
			n=(hw >> ((7-i)*4)) & 0xf;
			if (n<10) c=n+'0';
			else c=n-10+'A';
		} 
		else if (i<16) {
			n=(lw >> ((7-i)*4)) & 0xf;
			if (n<10) c=n+'0';
			else c=n-10+'A';
		} 
		else if (i==16) c=13; 
		else c=10;
		if (writechar(c)) return;
	}
}
	
void load_pattern(unsigned int *pattern, int nrofwords, int period) {
	unsigned int *p=pattern;
	int i;
	*pattern_period = period;
	*pattern_control = 3;
	for (i=0; i<nrofwords; i++) *pattern_data = *p++;
	*pattern_control = 1;
}

void main(void) {
	int i, j;
	int phase=0;
	unsigned int errors=0;
	unsigned int corrections=0;
	unsigned int hw,lw,cw,phasestat,prev_phasestat;
	int nrofwords=10;
	int n=0;
	int phasedownwards=0;
	char k;
	unsigned int pattern[10] = {0xff,0,0xff,0,0x55,0xaa,0,0xff,0xff,0};
	*singlepulse_control = 1;
	*singlepulse_delay = 100;
	*singlepulse_duration = 200;
	*rs232_control = 1;	
	*readtime_control = 8; // clear counters
	*BuTiSclock_control = 0x2; // re-sync
	for (j = 0; j < 1250000/4/5; ++j)  // 0.002s
		asm("# noop"); /* no-op the compiler can't optimize away */
	*BuTiSclock_control = 0x4; // reset phase PLL
	*BuTiSclock_lw = 0x00000000; 
	*BuTiSclock_hw = 0x00000000;
	*BuTiSclock_control = 0x1; // set the timestamp (hw & lw) on the next PPS-pulse
	phase=20;
	*BuTiSclock_control = phase << 8;
	*pattern_period = 1085;
	load_pattern(pattern,nrofwords,1085);
	while (1) {

		for (i = 0; i < 8; ++i) {
			if ((*readtime_errors!=errors) || (*readtime_corrections!=corrections)) {
				errors=*readtime_errors;
				corrections=*readtime_corrections;
				writestring("errors=");
				writestring(itoa(*readtime_errors));
				writestring("  corrections=");
				writestring(itoa(*readtime_corrections));
				writestring("\n\r");
			}
			
			*readtime_control = 0x1; // disable updating timestamp reading registers
			hw = *readtime_highword;
			lw = *readtime_lowword;
			cw = *readtime_control;
			*readtime_control = 0x0; // enable updating timestamp reading registers
			printhex(hw,lw,cw);
			phasestat=*BuTiSclock_status & 0x3;
			if ((phasestat & 0x2) && (!(prev_phasestat & 0x2))) {
//			if (n++>0) {
/*
				if (phasedownwards) {
					if (--phase<=0) phasedownwards=0;
				}
				else {
					if (++phase>=27) phasedownwards=1;
				}
				*BuTiSclock_control = phase << 8;
				n=0;
				writestring("phase=");
				writestring(itoa(phase));
				writestring("\n\r");
*/
//				writestring("resync ------------------------------------------\n\r");
//				*BuTiSclock_control = 0x2; // re-sync
			}
			prev_phasestat=phasestat;
			switch(phasestat) {
				case 0x0 : k=' '; break; // first half second of PPS phase
				case 0x1 : k='s'; break; // first half second of PPS phase and timestamp setting waiting for PPS
				case 0x2 : k='.'; break; // second half second of PPS phase
				case 0x3 : k='S'; break; // second half second of PPS phase and timestamp setting waiting for PPS
				default  : k='*';
			}
			if (writechar(k)) return;
			
			/* Rotate the LEDs */
			*leds = 1 << i;
			*singlepulse_delay = 100+i*10;
			*singlepulse_duration = 200+i*20;

			  /* Each loop iteration takes 4 cycles.
			   * It runs at 125MHz.
			   * Sleep 0.2 second.
			   */
			  for (j = 0; j < 125000000/4/5; ++j) {
				asm("# noop"); /* no-op the compiler can't optimize away */
			  }
		}
	}
}
