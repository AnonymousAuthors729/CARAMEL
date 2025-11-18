/**
 * Adam Caulfield
 * 
 * ACFA Software TCB
 * 
 * wrapper.c
 * 
 * Executes each part of the ACFA TCB (Attest, Wait, Heal)
 * 
*/

#include <string.h>
#include "hardware.h"

// Watchdog timer
#define WDTCTL_              0x0120    /* Watchdog Timer Control */
#define WDTHOLD             (0x0080)
#define WDTPW               (0x5A00)

// KEY
#define KEY_ADDR 0x6A00
#define KEY_SIZE 32 // in bytes

// METADATA
#define CHAL_BASE       0x180 //180-19f
#define CHAL_SIZE       32 // in bytes
#define METADATA_ADDR   CHAL_BASE+CHAL_SIZE
#define ERMIN_ADDR      METADATA_ADDR //1a0-1
#define ERMAX_ADDR      ERMIN_ADDR+2  //1a2-3
#define CLOGP_ADDR      ERMAX_ADDR+2  //1a4-5
//new stuff
#define TOPSLICE        CLOGP_ADDR+2  //1a6-7 - address in Metadata where top slice is stored
#define BOTTOMSLICE     TOPSLICE+2    //1a8-9  - address in Metadata where bottom slice is stored
#define LOGSTATE        BOTTOMSLICE+2 //1aa-b - address in Metadata where log state flag is set
#define VRF_RESPONSE    LOGSTATE+2 //1ac-d  - address in Metadata where vrf response flag is set
#define METADATA_SIZE   14
#define RESP_ADDR       VRF_RESPONSE+2 //starts at 1ae
// CFLog
#define LOG_BASE       0x6b00// 0x222 //we might be moing this around my problem child
// #define LOG_SIZE        256 // in bytes
// #define LOG_SIZE        512 
// #define LOG_SIZE        1024
#define LOG_SIZE        2048
// #define LOG_SIZE        4096 // 4kb
// #define LOG_SIZE        8192  // 8kb
//#define LOG_SIZE        12288 // 12kb
#define VRF_AUTH        0x1d0

// Set ER_MIN/MAX based on setting
#define PMEM_MIN  0xE000
#define PMEM_MAX  &acfa_exit
#define ER_MIN  PMEM_MIN
#define ER_MAX  PMEM_MAX

#define ER_MIN_LIEND  0x00E0
#define ER_MAX_LIEND  0x7AE1

// Timmer settings
#define TIMER_1MS 125 
#define MAX_TIME  0xffff
#define ACFA_TIME MAX_TIME // 50*TIMER_1MS // Time in ms -- note vivado sim is 4x faster

// Communication
#define DELAY     100
#define UART_TIMEOUT   0x167FFE
#define ACK       'a'

// Attested Program memory range
#define ATTEST_DATA_ADDR   0xe000
// #define ATTEST_SIZE        0x1fff //8kb
// #define ATTEST_SIZE        0x0fff //4kb
// #define ATTEST_SIZE        0x07ff //2kb
#define ATTEST_SIZE        0x03ff //1kb

// Protocol temp variable addresses
#define NEW_CHAL_ADDR         0xba4
#define TMP_BUFF           0xbc4
#define LOG_BASE_XS   0xca6
#define CHAL_XS 0xb40
#define PRV_AUTH 0xb60

// TCB version // AUTOMATED: Do not edit
#define NOT_SIM   0
#define SIM   1
#define IS_SIM  NOT_SIM
//

//Global variable for what hmac needs send called oneTime 
int onetime = 0;

/**********     Function Definitions      *********/
__attribute__ ((section (".tcb.lib"))) void my_memset(uint8_t* ptr, int len, uint8_t val);
void my_memcpy(uint8_t* dst, uint8_t* src, int size);
int secure_memcmp(const uint8_t* s1, const uint8_t* s2, int size);
void tcb();
void tcb_attest();
void tcb_wait();
void Hacl_HMAC_SHA2_256_hmac_exit();
void tcb_exit();
void recvBuffer(uint8_t * rx_data, uint16_t size);
void sendCFLog(uint16_t size);
void sendBuffer(uint8_t * tx_data, uint16_t size);
void echo_tx_rx(uint8_t * data, uint16_t size);
void echo_rx_tx(uint8_t * data, uint16_t size);
// EXTERNAL FUNCTIONS
extern void acfa_exit();
// #if IS_SIM == NOT_SIM
extern void hmac(uint8_t *mac, uint8_t *key, uint32_t keylen, uint8_t *data, uint32_t datalen);
// #else
// #define hmac my_hmac
void sim_hmac(uint8_t *mac, uint8_t *key, uint32_t keylen, uint8_t *data, uint32_t datalen);
// #endif

/**********  CORE TCB    *********/
#pragma vector=TIMERA0_VECTOR
__interrupt __attribute__ ((section (".tcb.call"), naked))
void timer_slide(){
    __asm__ volatile("nop" "\n\t");
}

#pragma vector=FLUSH_VECTOR
__interrupt __attribute__ ((section (".tcb.call")))
void tcb_entry(){
    // __asm__ volatile("push    r11" "\n\t");
    // __asm__ volatile("push    r4" "\n\t");
    // __asm__ volatile("mov    r1,    r4" "\n\t");

    
    // Call TCB Body:


    tcb();

    // Release registers
    // __asm__ volatile("pop    r4" "\n\t");
    __asm__ volatile("pop    r12" "\n\t");
    __asm__ volatile("pop    r13" "\n\t");
    __asm__ volatile("pop    r14" "\n\t");
    __asm__ volatile("pop    r15" "\n\t");

    __asm__ volatile("br #__tcb_leave" "\n\t");
}

__attribute__ ((section (".fini9"), naked)) void acfa_exit(){
    // __asm__ volatile("nop" "\n\t");
    __asm__ volatile("nop" "\n\t");
    __asm__ volatile("nop" "\n\t");
    __asm__ volatile("nop" "\n\t");
    // Pause Timer
    // TACTL &= ~MC_1;
    //Clear timer
    // TAR = 0x00;
    __asm__ volatile("jmp $+0" "\n\t");
}

__attribute__ ((section (".tcb.body"))) uint16_t get_ER_MIN(){
    return *((uint16_t*)(ERMIN_ADDR));
}

__attribute__ ((section (".tcb.body"))) uint16_t get_ER_MAX(){
    return  *((uint16_t*)(ERMAX_ADDR));
}

__attribute__ ((section (".tcb.body"))) void set_ER_MIN(uint16_t er_min){
    *((uint16_t*)(ERMIN_ADDR)) = er_min;
    P3OUT = *((uint8_t*)(0x67ee));
}

__attribute__ ((section (".tcb.body"))) void set_ER_MAX(uint16_t er_max){
    *((uint16_t*)(ERMAX_ADDR)) = er_max;
}

uint8_t pass;
__attribute__ ((section (".tcb.body"))) void validate_msg(){
    uint8_t * key = (uint8_t*)(KEY_ADDR);
    uint8_t * vrf_auth = (uint8_t*)(VRF_AUTH); // 32 bytes
    uint8_t * new_chal = (uint8_t*)(VRF_AUTH+32); // 32 bytes
    uint8_t * app = (uint8_t*)(VRF_AUTH+64); // 2 bytes

    uint8_t * auth = (uint8_t*)(PRV_AUTH); //expected auth token from vrf computed by prv
    for(int i=0; i<32; i++){ // dummy vals for quicker sim
        auth[i] = 0;
    }

    // hmac(auth, key, (uint32_t) KEY_SIZE, new_chal, (uint32_t) CHAL_SIZE);
    // hmac(auth, auth, (uint32_t) KEY_SIZE, app, (uint32_t) 2);

    pass = 0;
    P3OUT = 0;
    for(int i=0; i<CHAL_SIZE; i++){
        if (vrf_auth[i] != auth[i]){
            pass |= 1; // upper bit of pass is (1: not equal, 0: equal) // change back to |= 2 after debug
        } else {
            pass |= 0;
        }
    }
    // lower bit of pass is app
    int app_int = *((int *)app);
    pass |= (uint8_t)(0x1 & app_int);
    P3OUT = pass;

    if(pass >= 2){ // if pass is 2 or 3, that means inauth vrf
        //Reset the response flag --> return to waiting for next response
        *((uint16_t*)(VRF_RESPONSE)) = 0x00; //
    } else{
        // pass is either 0:heal or 1:cont
        if (pass == 1){
            *((uint16_t*)(VRF_RESPONSE)) = 0x00; //
            tcb_allclear(); 
        } else {
            tcb_heal();
        }
    }
}

__attribute__ ((section (".tcb.body"))) void tcb_heal() {
    // "Shut Down"
    _BIS_SR(CPUOFF);

    // "Reset"
    //((void(*)(void))(*(uint16_t*)(0xFFFE)))();
}

int boot = 0;
__attribute__ ((section (".tcb.body"))) void tcb() {

    /********** SETUP ON ENTRY **********/
    // Switch off the WTD
    uint32_t* wdt = (uint32_t*)(WDTCTL_);
    *wdt = WDTPW | WDTHOLD;

    // // Configure Timer A0 for timeout
    // CCTL0 = CCIE;                            // CCR0 interrupt enabled
    // CCR0  = ACFA_TIME;                     // Set based on time
    // TACTL = TASSEL_2 + MC_1 + ID_3;          // SMCLK, contmode

    // // Pause Timer
    // TACTL &= ~MC_1;
    // //Clear timer
    // TAR = 0x00;

    // Init UART
    UART_BAUD = BAUD;                   
    UART_CTL  = UART_EN;

    P3DIR |= 0xff;

    // #if IS_SIM == NOT_SIM
    // // /********** TCB ATTEST **********/
// Save current value of r5 and r6:
    __asm__ volatile("push    r5" "\n\t");
    __asm__ volatile("push    r6" "\n\t");

    // Save return address
    __asm__ volatile("mov    #0x0012,   r6" "\n\t");
    __asm__ volatile("mov    #0x500,   r5" "\n\t");
    __asm__ volatile("mov    r0,        @(r5)" "\n\t");
    __asm__ volatile("add    r6,        @(r5)" "\n\t");

    // Save the original value of the Stack Pointer (R1):
    __asm__ volatile("mov    r1,    r5" "\n\t");

    // Set the stack pointer to the base of the exclusive stack:
    __asm__ volatile("mov    #0x1704,     r1" "\n\t");

    // tcb_attest(); // monitored by VRASED
    volatile uint16_t vrf_resp = *(volatile uint16_t*)(VRF_RESPONSE);
    // P3OUT = 0xad; // sim visible break 
    // P3OUT = ((vrf_resp & 0xff00) >> 8);
    // P3OUT = (vrf_resp & 0x00ff);
    unsigned int log = *((uint16_t*)(LOGSTATE));
    // P3OUT = 0xad; // sim visible break 
    // P3OUT = ((log & 0xff00) >> 8);
    // P3OUT = (log & 0x00ff);


/////memory debugging //// Remove when vrased is integrated!!!!
/////memory debugging //// Remove when vrased is integrated!!!

//left over testing
    // P1OUT = *((uint8_t*)(0x6b00));


    // int8_t * cflog = (uint8_t * )(LOG_BASE);
    // unsigned int i;
    // for(i=0; i<LOG_SIZE; i++){
    //     // cflog[i] = i;
    //     P3OUT = cflog[i];
    // }



    if (vrf_resp != 1){
        switch (log)
        {
        case 0:// after boot/reset attest the full log
            P3OUT = 0xa0; // sim visible break
            tcb_attest(); 
            tcb_sendoff();
            break;

        case 1://preparing a slice(s) we want to send
            P3OUT = 0xa1; // sim visible break
            tcb_attest();
            tcb_sendoff();
            break;

        case 2://cflog is full there for we just want to call wait
            P3OUT = 0xa2; // sim visible break
            tcb_wait();
            //but then we want to send the remaining log just an idea....
            tcb_attest();
            tcb_sendoff();
            break;

        case 3://cflog is full  but we want to send the full log first then enter wait
            P3OUT = 0xa3; // sim visible break
            tcb_attest();
            tcb_sendoff();
            tcb_wait();
            break;                

        default:
            break;
        }
    } else {
        validate_msg();
    }

    // Copy retrieve the original stack pointer value:
    __asm__ volatile("mov    r5,    r1" "\n\t");

    // // Restore original r5,r6 values:
    __asm__ volatile("pop   r6" "\n\t");
    __asm__ volatile("pop   r5" "\n\t");
    // #endif

    // #if IS_SIM == SIM
    // tcb_attest();

    // *((uint16_t*)(ERMIN_ADDR)) = ER_MIN;
    // P1OUT = *((uint8_t*)(ERMIN_ADDR));
    // P1OUT = *((uint8_t*)(ERMIN_ADDR+1));
    // *((uint16_t*)(ERMAX_ADDR)) = ER_MAX;
    // P1OUT = *((uint8_t*)(ERMAX_ADDR));
    // P1OUT = *((uint8_t*)(ERMAX_ADDR+1));
    // uint16_t * er_min = (uint16_t*)(ERMIN_ADDR);
    // uint16_t * er_max = (uint16_t*)(ERMIN_ADDR);
    // #endif


    //initial set up will only happen once at first boot
    if (boot == 0)
    {

        volatile uint16_t * vrf_msg = (volatile uint16_t*)(VRF_AUTH);
        // while (vrf_msg[0] != ER_MIN && vrf_msg[0] != ER_MIN_LIEND);
        // set the beginning of ER in this protoype it stays alwqays the same at /e000 the beginning of PMEM (if PMEM changes this will not automatically adjust)
        set_ER_MIN(ER_MIN);
        
        // this is our protoypes wait for inistial challenge from vrf which will set the end of ER and will only be accepted if it is the same as the expected value
        while (vrf_msg[32] != ER_MAX && vrf_msg[32] != ER_MAX_LIEND);
        // {
            // P3OUT = ((vrf_msg[32]  & 0xff00) >> 8);
            // P3OUT = (vrf_msg[32]  & 0x00ff);
        // }
    
        set_ER_MAX(vrf_msg[32]);
        boot = 1;
    }

    // Resume Timer on exit
    TACTL |= MC_1; 
    
    return;
}

/********** TCB ATTEST ************/ 
__attribute__ ((section (".tcb.attest"))) void tcb_attest()
{
 
    // #if IS_SIM == SIM
    // uint8_t * cflog = (uint8_t * )(LOG_BASE);
    // unsigned int i;
    // for(i=0; i<LOG_SIZE; i++){
    //     P1OUT = cflog[i];
    // }

    // #else
    // addrs for each obj
    // uint8_t * tmp = (uint8_t*)(TMP_BUFF);
    uint8_t * key = (uint8_t*)(KEY_ADDR);
    uint8_t * metadata = (uint8_t*)(METADATA_ADDR);
    uint8_t * response = (uint8_t*)(RESP_ADDR);
    unsigned int top_idx = *((uint16_t*)(TOPSLICE));
    unsigned int bottom_idx = *((uint16_t*)(BOTTOMSLICE));//200 but 512

    //unsigned int log = *((uint16_t*)(LOGSTATE)); Can't use boot to determine if first attest as we attest pmem with the first report which is a flush

    P3OUT = 0xaa;
    // my_memcpy((uint8_t*)(LOG_BASE_XS), (uint8_t*)(LOG_BASE), LOG_SIZE); //why do we do this?
    P3OUT =0;
    P3OUT = 0xaa;
    my_memcpy((uint8_t*)(CHAL_XS), (uint8_t*)(CHAL_BASE), CHAL_SIZE);

    P3OUT = 0xac;
    hmac(response, key, (uint32_t) KEY_SIZE, (uint8_t*)(CHAL_XS), (uint32_t) CHAL_SIZE);
    hmac(response, response, (uint32_t) KEY_SIZE, metadata, (uint32_t) METADATA_SIZE);
    
    // output top/bottom indices for debug
    P3OUT = (uint8_t)((top_idx >> 8) & 0xFF);
    P3OUT = (uint8_t)(top_idx & 0xFF);
    P3OUT = 0x11;
    P3OUT = (uint8_t)((bottom_idx >> 8) & 0xFF);
    P3OUT = (uint8_t)(bottom_idx & 0xFF);
    P3OUT = 0x11;

    if(top_idx < bottom_idx){
        P3OUT = 0xab;
        
        uint8_t * data_ptr = ((uint8_t*)(LOG_BASE)) + top_idx;
        // P3OUT = data_ptr;
        uint32_t data_len = (uint32_t)((bottom_idx - top_idx)*2u);
        //P3OUT = (uint8_t*)data_ptr;
        //P3OUT = 0x11;
        //P3OUT = (uint8_t)((data_len >> 8) & 0xFF);
        //P3OUT = (uint8_t)(data_len & 0xFF);
        //P3OUT = 0x11;
        // P3OUT = data_len;
        // my_memcpy((uint8_t*)(LOG_BASE_XS), (uint8_t*)(LOG_BASE), data_len);
        hmac(response, response, (uint32_t) KEY_SIZE, (uint8_t*)data_ptr, (uint32_t) data_len);

        P3OUT = 0;
    }else {
        // full log
        P3OUT = 0xba;
        // hmac(response, response, (uint32_t) KEY_SIZE, (uint8_t*)(LOG_BASE_XS), LOG_SIZE);
        uint8_t * data_ptr = ((uint8_t*)(LOG_BASE)) + top_idx;
        uint32_t data_len = (uint32_t)(((LOG_SIZE/2) - top_idx)*2u);
        // my_memcpy((uint8_t*)(LOG_BASE_XS), (uint8_t*)(LOG_BASE), data_len1);
        hmac(response, response, (uint32_t) KEY_SIZE, data_ptr, data_len);
        P3OUT = 0;
        P3OUT = 0xba;
        uint8_t *data_ptr2 = ((uint8_t*)(LOG_BASE));
        uint32_t data_len2 = (uint32_t)((bottom_idx)*2u);
        // my_memcpy((uint8_t*)(LOG_BASE_XS), (uint8_t*)(LOG_BASE), data_len2);
        hmac(response, response, (uint32_t) KEY_SIZE, data_ptr2, data_len2);
        P3OUT = 0;
    }
    
    if(onetime == 0){ //
        onetime = 1;
        P3OUT = 0xbe; // sim visible break  
        hmac(response, response, (uint32_t) KEY_SIZE, (uint8_t*)(ATTEST_DATA_ADDR), (uint32_t) ATTEST_SIZE);
    }
   

    // tcb_wait();

    // restore return address
    __asm__ volatile("mov    #0x500,   r6" "\n\t");
    __asm__ volatile("mov    @(r6),     r6" "\n\t");

    // postamble -- check LST, add all insts before "ret"
    // __asm__ volatile("incd  r1" "\n\t");
    // __asm__ volatile("pop   r7" "\n\t");
    // __asm__ volatile("pop   r8" "\n\t");
    __asm__ volatile("pop   r9" "\n\t");
    __asm__ volatile("pop   r10" "\n\t");
    __asm__ volatile("pop   r11" "\n\t");
    // #endif

    // safe exit
    __asm__ volatile( "br      #__mac_leave" "\n\t");
}

/******** CARAMEL PRE-EXITS *******/
// tcb_sendoff is called when the TCB is done and the log is send off it also triggers the Communication module
__attribute__ ((section (".tcb.sendoff"), naked)) void tcb_sendoff() {
      //after computing hmac 
    __asm__ volatile("ret" "\n\t");
}

// tcb_allclear is called when the TCB is done evaluating the response and everything is ok sets the vrf_responded flag in log monitor
__attribute__ ((section (".tcb.allclear"), naked)) void tcb_allclear() { //after resonsverified no action necessary
    __asm__ volatile("ret" "\n\t");
}
////

__attribute__ ((section (".do_mac.leave"))) __attribute__((naked)) void Hacl_HMAC_SHA2_256_hmac_exit() 
{
  __asm__ volatile("ret" "\n\t");
}

__attribute__ ((section (".tcb.leave"), naked)) void tcb_exit() {
    __asm__ volatile("reti" "\n\t");
}

/************* TCB WAIT *********/
__attribute__ ((section (".tcb.body"))) void tcb_wait(){
    pass = 0;
    unsigned int vrf_responded = *((uint16_t*)(VRF_RESPONSE)); 
    while(pass == 0){
        while(vrf_responded == 0); // set by CM-UART upon recv
        validate_msg(); // received something, so now we need to validate it
        // exits if pass != 0
    }
}

 /**********  UTILITY    *********/
// #if IS_SIM == SIM
__attribute__ ((section (".tcb.wait"))) void sim_hmac(uint8_t *mac, uint8_t *key, uint32_t keylen, uint8_t *data, uint32_t datalen){
    uint32_t i;
    for(i=0; i<keylen; i++){
        P1OUT = data[i];
    }
}
// #endif

__attribute__ ((section (".tcb.lib"))) void my_memset(uint8_t* ptr, int len, uint8_t val) {
  int i=0;
  for(i=0; i<len; i++) ptr[i] = val;
}

__attribute__ ((section (".tcb.lib"))) void my_memcpy(uint8_t* dst, uint8_t* src, int size) {
    // *((uint8_t*)(0x7700)) = 1;
    // P3OUT = *((uint8_t*)(0x7700));
    int i=0;
    for(i=0; i<size; i++) {
        // P3OUT = src[i];
        dst[i] = src[i];}
}

__attribute__ ((section (".tcb.lib"))) int secure_memcmp(const uint8_t* s1, const uint8_t* s2, int size) {
    int res = 1;
    int first = 1;
    for(int i = 0; i < size; i++) {
      if (first == 1 && s1[i] > s2[i]) {
        res = 0;
        first = 0;
      }
      else if (first == 1 && s1[i] < s2[i]) {
        res = 0;
        first = 0;
      }
    }
    return res;
}