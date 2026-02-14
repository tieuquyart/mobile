
#ifndef __EYESIGHT_DMS_DATA_H__
#define __EYESIGHT_DMS_DATA_H__

#define EYESIGHT_DMS_DATA_FCC		0x444D5331	// DMS1
#define EYESIGHT_DMS_DATA_REG_NAME	"avf.dms.eyesight"
//#define EYESIGHT_DMS_DATA_VERSION	3	// eyesight 7.1.2
//#define EYESIGHT_DMS_DATA_VERSION	4	// eyesight 7.2.10
//#define EYESIGHT_DMS_DATA_VERSION	5	// eyesight 7.4 beta
//#define EYESIGHT_DMS_DATA_VERSION	6	// eyesight 7.4 beta 5
//#define EYESIGHT_DMS_DATA_VERSION	7	// eyesight 7.5.5
//#define EYESIGHT_DMS_DATA_VERSION	8	// eyesight 7.6.3
#define EYESIGHT_DMS_DATA_VERSION	9	// eyesight 7.10.4
#define EYESIGHT_DMS_DATA_REVISION	1

#define EYESIGHT_DATA_F_L1_HAS_INTERNAL_DATA	(1 << 0)
#define EYESIGHT_DATA_F_L1_HAS_PERSON_ID		(1 << 1)

typedef struct eyesight_dms_data_header_s {
	uint32_t version;
	uint32_t revision;
	uint16_t src_width;		// input video size
	uint16_t src_height;
	uint16_t input_xoff;	// a rectangle in input video
	uint16_t input_yoff;
	uint16_t input_width;
	uint16_t input_height;
	uint16_t dms_width;		// after resizing
	uint16_t dms_height;
	uint32_t flags;
	uint32_t isDriverValid;	// 0 for level 0; 1 for level 1
	uint32_t level;			// 0: no data; 1: L1; 2: L2; 0x00010002: L2 list
	uint32_t data_size;
} eyesight_dms_data_header_t;

typedef struct eyesight_person_info_s {
	uint32_t faceid_lo;
	uint32_t faceid_hi;
	uint8_t name[32];
	uint32_t person_id;
} eyesight_person_info_t;

// should include DriverSenseEngine.h

typedef struct eyesight_dms_data_old_s {
//	if (header.level == 1) {
//		struct L1Output l1output;
//		if (header.flags & EYESIGHT_DATA_F_L1_HAS_INTERNAL_DATA) {
//			struct L1Internal internal;
//		}
//		if (header.flags & EYESIGHT_DATA_F_L1_HAS_PERSON_ID) {
//			eyesight_person_info_t personInfo;
//		}
//	} else if (header.level == 2) {
//		struct L2Output l2output;
//	}
} eyesight_dms_data_old_t;

typedef struct eyesight_l2output_list_s {
//	uint32_t num_l2output;
//	struct L2Output l2output[num_l2output];
} eyesight_l2output_list_t;

typedef struct eyesight_dms_data_v5_s {
//	if (header.level == 1) {
//		uint32_t l1output_size;
//		struct L1Output l1output;
//		if (header.flags & EYESIGHT_DATA_F_L1_HAS_PERSON_ID) {
//			uint32_t person_size;
//			eyesight_person_info_t person;
//		}
//	} else if (header.level == 2) {
//		uint32_t l2output_size;
//		struct L2Output l2output;
//	} else if (header.level == 0x00010002) {
//		eyesight_l2output_list_t l2output_list;
//	}
} eyesight_dms_data_v5_t;

typedef struct eyesight_dms_data_s {
	eyesight_dms_data_header_t header;
//	if (header.version >= 5)
//		eyesight_dms_data_v5_t data_new;
//	else if (header.version <= 4)
//		eyesight_dms_data_old_t data_old;
//	else
//		error;
} eyesight_dms_data_t;

#endif

