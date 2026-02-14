//
//  ccam_cmd.h
//  Vidit
//
//  Created by gliu on 15/2/3.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#ifndef __Vidit__ccam_cmd__
#define __Vidit__ccam_cmd__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <libxml/parser.h>
#include <libxml/tree.h>
#include <libxml/xmlwriter.h>

#include "ccam_cmds.h"

#define envelop_root_element_name "ccev"
#define envelop_attr_type_name "tp"
#define envelop_attr_time_name "st"
//const static char* cmd_attr_para1 = "id";
#define cmd_element_name "cmd"
#define cmd_attr_action "act"
#define cmd_attr_para1 "p1"
#define cmd_attr_para2 "p2"
#define cmd_attr_sn "sn"
#define cmd_attr_id "id"


/***************************************************************
 StringCMD
 */
class StringCMD
{
public:
    StringCMD
    (char* name = NULL
     , char* para1 = NULL
     , char* para2 = NULL
     );
    ~StringCMD();

    void copyName(char* name);
    void copyPara1(char* para1);
    void copyPara2(char* para2);
    void copyFromID(char* from);
    void setSequence(char* seq);

    unsigned int getSeq(){return _sequence;};
    char* getName(){return _name;};
    const char* getPara1(){return _para1;};
    const char* getPara2(){return _para2;};
    char* getFromID(){return _from;};

    void setLock(){_bLock = true;};
    bool isLock(){return _bLock;};

private:
    unsigned int _sequence;
    char *_name;
    char *_para1;
    char *_para2;
    bool _bOut;
    bool _bLock;
    char *_from;
};

enum EnvelopeType
{
    EnvelopeType_cmd = 0,
    EnvelopeType_offline_cmd,
    EnvelopeType_state,
};

/***************************************************************
 StringEnvelope
 */
#define in_envelope_max_cmd_num 10
class StringEnvelope
{
public:
    StringEnvelope(StringCMD** cmds,int num);//, StringController* pController);
    StringEnvelope(char* buf ,int length);
    ~StringEnvelope();
    static bool isEnvelope(char* buf, int len);
    void print();
    bool isNotEmpty();
    int getNum(){return _num;};
    StringCMD* GetCmd(int i){return _cmds[i];};
    char* getBuffer(){return _buffer;};
    int getBufferLen(){return _bufferLen;};
private:
    StringCMD*	_cmds[in_envelope_max_cmd_num];
    int			_num;
    unsigned int		_sendtime; //UTC time when this was send out.
    //StringController* _pController;
    bool 		_bOut;
    int			_type;
    char		*_buffer;
    int			_bufferLen;


private:
    void ParseCmd(xmlNode* root_element);
    void SendOut();

};

class SCMD_Domain;
class EnumedStringCMD : public StringCMD
{
public:
    typedef StringCMD inherited;
    EnumedStringCMD  // FOR Reciever
    (SCMD_Domain* pDomain
     , int cmd
     );

    EnumedStringCMD // FOR Sendor
    (int domain
     , int cmd
     ,char* para1
     ,char* para2
     );
    ~EnumedStringCMD();

    int	getDomain();
    int getCMD();
    bool isCmd(int cmd){return cmd == _cmd;};
    //bool isEnumedCMD();
    //virtual int execute(EnumedStringCMD* p);
    //SCMD_Domain* getDomainObj(){return _pDomain;};
    //void Send(EnumedStringCMD* tricker);

private:
    char	_cmdBuffer[64];
    int		_cmd;
    SCMD_Domain* _pDomain;
};

class SCMD_Domain
{
public:
    SCMD_Domain(int domain, int cmdNum);
    ~SCMD_Domain();

    int getDomain(){return _domain;};
    EnumedStringCMD* searchCMD(int cmd);
    //void register(EnumedStringCMD* cmd);
    void Register(EnumedStringCMD*);
protected:
    int					_iPropNum;

private:
    int _domain;
    EnumedStringCMD**	_ppRegistedCmds;
    int					_CmdsListLenght;
    int					_addedNum;
};

#define SCMD_CMD_CLASS(name,index) \
class ccam_cmd_##name : public EnumedStringCMD \
{ \
public:	\
typedef EnumedStringCMD inherited ;\
ccam_cmd_##name(SCMD_Domain* domain):inherited(domain, index)\
{\
};\
~ccam_cmd_##name();\
\
virtual int execute(EnumedStringCMD* p);\
private:\
};

#define SCMD_CMD_EXECUTE(name) \
int ccam_cmd_##name::execute(EnumedStringCMD* p)

#define SCMD_CMD_NEW(name, domainObj)\
new ccam_cmd_##name(domainObj)

#define SCMD_DOMIAN_CLASS(name)\
class ccam_domain_##name : public SCMD_Domain \
{\
public:	\
typedef SCMD_Domain inherited ;\
ccam_domain_##name();\
~ccam_domain_##name();\
};

#define SCMD_DOMIAN_CONSTRUCTOR(name,domain,num) \
ccam_domain_##name::ccam_domain_##name\
():inherited(domain, num)

#define SCMD_DOMIAN_DISTRUCTOR(name) \
ccam_domain_##name::~ccam_domain_##name()

#define SCMD_DOMAIN_NEW(domainName)\
new ccam_domain_##domainName()


#endif /* defined(__Vidit__ccam_cmd__) */
