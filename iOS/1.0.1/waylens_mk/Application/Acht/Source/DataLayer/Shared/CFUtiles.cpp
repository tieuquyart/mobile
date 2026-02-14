

#include <string.h>
#include <unistd.h>
#include <stdlib.h>

#import <CommonCrypto/CommonCrypto.h>

#include "CFUtiles.h"

static char HEX_LOWER_CODES[] = "0123456789abcdef";
static char HEX_UPPER_CODES[] = "0123456789ABCDEF";

int cf_encode_hex(unsigned char *input, unsigned int len, unsigned char *out, unsigned int *out_len, bool is_upper)
{
	if (*out_len < len*2) {
		return -1;
	}

	char *hex_codes_ = (is_upper ? HEX_UPPER_CODES : HEX_LOWER_CODES);
	int j = 0;
	unsigned int tmp_num = 0;
	for(unsigned int i=0; i<len; i++) {
		tmp_num  = input[i];
		out[j++] = hex_codes_[(tmp_num & 0xf0) >> 4];
		out[j++] = hex_codes_[tmp_num & 0x0f];
	}
	*out_len = j;
	return j;
}

int cf_decode_hex(unsigned char *input,unsigned int input_len,unsigned char *out,unsigned int *out_len)
{
	if (input_len/2 > (*out_len)) {
		return -1;
	}

	int j = 0;
	unsigned int tmp_num=0;
	for(unsigned int i=0; i<input_len; ++i) {
		tmp_num = 0;
		do {
			if (input[i] >= '0' && input[i] <= '9') {
				tmp_num += input[i]-'0';
			} else if (input[i] >= 'a' && input[i] <= 'f') {
				tmp_num += input[i]-'a'+10;
			} else if (input[i]>='A' && input[i]<='Z') {
				tmp_num += input[i]-'A'+10;
			} else {
				*out_len = 0;
				return -2;
			}

			if (i%2 == 0) {
				tmp_num <<= 4;
				i++;
			} else {
				out[j++] = tmp_num;
				break;
			}
		} while (i%2 == 1);
	}//for
	*out_len = j;

	return j;
}

