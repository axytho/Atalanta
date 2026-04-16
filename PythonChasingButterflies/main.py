import random
import math
from helpers import *
import logging
import sha3bit
import binascii
from kyber_py.ml_kem import ML_KEM_768
import hashlib

def generate_kyber_test():
    #message_hex =binascii.hexlify(message.encode()).decode('ascii')
    LOG_N_MIN_COEF = 3
    random.seed(6)
    result_K = open("KYBER_K_OUT.txt",'w')
    result_CT2 = open("KYBER_CT2_OUT.txt",'w')
    input = open("KYBER_IN.txt",'w')
    CLOCK_CYCLES=1<<LOG_N_MIN_COEF

    for i in range(8>>LOG_N_MIN_COEF):
        ek, dk = ML_KEM_768.key_derive(random.randbytes(64))
        ML_KEM_768.set_drbg_seed(random.randbytes(48))
        m = bytes(32)
        key, ct = ML_KEM_768._encaps_internal(ek, m)
        #logging.basicConfig(format='%(message)s', level='DEBUG')
        #sha_object = sha3bit.sha3_256(ek, verbose=True )
        #b = sha_object.hexdigest()
        #print(flip_hex_my_way(b)) #to check whether SHA-256 works
        #print(b)
        #padded_input = f"{value:0{padding}x}"
        ek_string = flip_hex_my_way(hexdigest(ek))
        input.write(ek_string + "\n")
        key_string = flip_hex_my_way(hexdigest(key))
        ct_string = flip_hex_my_way(hexdigest(ct))
        c2 = ct_string[:256]
        c1 = ct_string[256:]
        LEN = len(key_string)>>LOG_N_MIN_COEF
        LEN_CT_1_ONE_THIRD = len(c1)//3
        LEN_CT_1 = LEN_CT_1_ONE_THIRD>>LOG_N_MIN_COEF
        LEN_CT_2 = len(c2)>>LOG_N_MIN_COEF
        for j in range(CLOCK_CYCLES-1,-1, -1):
            result_K.write(key_string[LEN*j:LEN*(j+1)] + "\n")
            result_CT2.write(c2[LEN_CT_2*j:LEN_CT_2*(j+1)] +c1[LEN_CT_1*j:LEN_CT_1*(j+1)]
                             +c1[LEN_CT_1_ONE_THIRD+LEN_CT_1*j:LEN_CT_1_ONE_THIRD+LEN_CT_1*(j+1)]
                             + c1[2*LEN_CT_1_ONE_THIRD+LEN_CT_1*j:2*LEN_CT_1_ONE_THIRD+LEN_CT_1*(j+1)] + "\n")




def generate_sample_test():
    #message_hex =binascii.hexlify(message.encode()).decode('ascii')
    random.seed(1)
    result = open("SAMPLENTT_OUT.txt",'w')
    input = open("SAMPLENTT_IN.txt",'w')
    for i in range(24>>3):
        b = random.randbytes(840)
        input.write(flip_hex_my_way(hexdigest(b)) + "\n")
        resultList = ntt_sample(b)
        resultString = ""
        for i in range(N-1,-1,-1):
            resultString+=hex(resultList[i])[2:].zfill(3)
        result.write(resultString+ "\n")





def flip_hex_my_way(message):
    message_list = [message[2*i:2*i+2].zfill(2) for i in range(len(message)//2)]
    result_list = message_list[::-1]
    return "".join(result_list)

def hexdigest(bytesObject):
    """Like digest() except the digest is returned as a string
    of double length, containing only hexadecimal digits.
    """
    return binascii.hexlify(bytesObject).decode('ascii')

def check_other_implementation():
    message = "Hello World!"
    message_bytes = message.encode()
    sha_object = sha3bit.sha3_256(message.encode())
    b = sha_object.hexdigest()
    c = hashlib.sha3_256(message_bytes).digest()
    print(flip_hex_my_way(b))
    print(flip_hex_my_way(hexdigest(c)))

def generate_round_testvectors():
    #message_hex =binascii.hexlify(message.encode()).decode('ascii')
    random.seed(6)
    result = open("SHA3_OUT.txt",'w')
    input = open("SHA3_IN.txt",'w')
    for i in range(8>>3):
        message = str(random.randint(0,139412493))
        message =  ((768+256)//8-len(message))*"0"+message
        #logging.basicConfig(format='%(message)s', level='DEBUG')

        a = sha3bit.sha3_256(message.encode())
        b= a.hexdigest()
        #print(b)
        message_hex =binascii.hexlify(message.encode()).decode('ascii')
        #padded_input = f"{value:0{padding}x}"
        input.write(flip_hex_my_way(message_hex) + "\n")
        result.write(flip_hex_my_way(b) + "\n")

def generate_round_testvectors_shake256():
    #message_hex =binascii.hexlify(message.encode()).decode('ascii')
    random.seed(1)
    result = open("SHAKE256_OUT.txt",'w')
    input = open("SHAKE256_IN.txt",'w')
    for i in range(24>>3):
        message = str(random.randint(0,139412493))
        message =  ((256+8)//8-len(message))*"0"+message
        #logging.basicConfig(format='%(message)s', level='DEBUG')

        a = sha3bit.shake_256(message.encode())
        b= a.hexdigest(1024//8)
        #print(b)
        message_hex =binascii.hexlify(message.encode()).decode('ascii')
        #padded_input = f"{value:0{padding}x}"
        input.write(flip_hex_my_way(message_hex) + "\n")
        result.write(flip_hex_my_way(b) + "\n")

def generate_round_testvectors_shake256_stream_output():
    #message_hex =binascii.hexlify(message.encode()).decode('ascii')
    random.seed(1)
    result = open("SHAKE256_OUT_STREAM.txt",'w')
    input = open("SHAKE256_IN.txt",'w')
    SHIFTS_DOWN = 3
    for i in range(24>>SHIFTS_DOWN):
        message = str(random.randint(0,139412493))
        message =  ((256+8)//8-len(message))*"0"+message
        #logging.basicConfig(format='%(message)s', level='DEBUG')

        a = sha3bit.shake_256(message.encode())
        b= a.hexdigest(1024//8)
        #print(b)
        message_hex =binascii.hexlify(message.encode()).decode('ascii')
        #padded_input = f"{value:0{padding}x}"
        input.write(flip_hex_my_way(message_hex) + "\n")
        output_result_one_block = flip_hex_my_way(b)
        output_width = len(output_result_one_block)>>SHIFTS_DOWN
        for j in range(1<<SHIFTS_DOWN):
            result.write(output_result_one_block[-(output_width):] + "\n")
            output_result_one_block = output_result_one_block[:(-output_width)]


def generate_round_testvectors_shake256_one_third():
    #message_hex =binascii.hexlify(message.encode()).decode('ascii')
    random.seed(1)
    result = open("SHAKE256_OUT.txt",'w')
    input = open("SHAKE256_IN.txt",'w')
    for i in range(8>>3):
        message = str(random.randint(0,139412493))
        message =  ((256+8)//8-len(message))*"0"+message
        #logging.basicConfig(format='%(message)s', level='DEBUG')

        a = sha3bit.shake_256(message.encode())
        b= a.hexdigest(1024//8)
        #print(b)
        message_hex =binascii.hexlify(message.encode()).decode('ascii')
        #padded_input = f"{value:0{padding}x}"
        input.write(flip_hex_my_way(message_hex) + "\n")

        result.write(flip_hex_my_way(b) + "\n")

def generate_round_testvectors_shake128():
    #message_hex =binascii.hexlify(message.encode()).decode('ascii')
    random.seed(1)
    result = open("SHAKE128_OUT.txt",'w')
    input = open("SHAKE128_IN.txt",'w')
    for i in range(24>>3):
        message = str(random.randint(0,139412493))
        message =  ((256+8+8)//8-len(message))*"0"+message
        #logging.basicConfig(format='%(message)s', level='DEBUG')

        a = sha3bit.shake_128(message.encode())
        b= a.hexdigest(1344*5//8)
        #print(b)
        message_hex =binascii.hexlify(message.encode()).decode('ascii')
        #padded_input = f"{value:0{padding}x}"
        input.write(flip_hex_my_way(message_hex) + "\n")
        result.write(flip_hex_my_way(b) + "\n")

def generate_round_testvectors_512():
    #message_hex =binascii.hexlify(message.encode()).decode('ascii')
    random.seed(6)
    result = open("SHA3_512_OUT.txt",'w')
    input = open("SHA3_512_IN.txt",'w')
    for i in range(8>>3):
        message = str(random.randint(0,139412493))
        message =  ((512)//8-len(message))*"0"+message
        #logging.basicConfig(format='%(message)s', level='DEBUG')

        a = sha3bit.sha3_512(message.encode())
        b= a.hexdigest()
        #print(b)
        message_hex =binascii.hexlify(message.encode()).decode('ascii')
        #padded_input = f"{value:0{padding}x}"
        input.write(flip_hex_my_way(message_hex) + "\n")

        result.write(flip_hex_my_way(b) + "\n")


def print_testvector_round():
    #message_hex =binascii.hexlify(message.encode()).decode('ascii')
    random.seed(1)

    for i in range(1):
        message = str(random.randint(0,139412493))
        message =  ((256+8)//8-len(message))*"0"+message
        logging.basicConfig(format='%(message)s', level='DEBUG')

        a = sha3bit.shake_128(message.encode(), verbose=True)
        b= a.hexdigest(1344*5//8)
        #print(b)
        message_hex =binascii.hexlify(message.encode()).decode('ascii')
        #padded_input = f"{value:0{padding}x}"


def generate_ntt_parameters(modulus, LOG_N, TWIDDLE_2N):
    K = modulus-1
    while (K%2!=1):
        K = K>>1
    print(f'// NTT application-specific user-defined parameters\n\
// i.e. the cryptographical algorithm usually decides what goes here\n\
// although the user may have some lattitude in picking the modulus\n\
// (contact your local cryptographer for more details)\n\
`define LOG_N {LOG_N}\n\
`define MODULUS 12\'b{bin(modulus)[2:]}\n\
`define TWIDDLE_2N {TWIDDLE_2N}\n\
\n\
\n\
\n\
// python program defined parameters (for stuff too complicated to generate through verilog functions)\n\
`define INVERSE_TWIDDLE_2N {pow(TWIDDLE_2N, -1, modulus)} //INVERSE_TWIDDLE_2N = pow(TWIDDLE_2N, -1, MODULUS)\n\
`define PRECOMP_FACTOR   1 //butterfly multiplier precomp factor,\n\
                           //will always be one unless you change modular reduction\n\
                           //inside the butterflies to use something that isn\'t LUT\n\
`define NUMBER_OF_PRECOMPS_NECESSARY   1 //1 if you only do K-reduction in the multiplier halfway,\n\
                                         //3 if you use it for tail reduction as well \n\
                                         //can be anything depending on number of multipliers \n\
                                         //For the full NTT case, find a way to remove K \n\
                                         //from the coefficient-wise multiplication \n\
`define PRECOMP_FACTOR_NORMAL_MULT   {pow(-K, -1, MODULUS)} // for multiplication outside butterflies\n\
                                            // if K-reduction, should be equal to\n\
                                            // pow(-K, -1, MODULUS)\n\
                                            // with K so that MODULUS = K << SHIFT + 1\n\
                                            // for some SHIFT\n\
`define REDUCED_POLYNOMIAL_DEPTH {max(0, LOG_N - int(math.log2(math.gcd(2**LOG_N,modulus-1)))+1)} // = max(0, LOG_N - log2(gcd(2^LOG_N,MODULUS-1))+1)\n\
// i.e. the highest power of two that divided modulus -1, figure out what this power is and\n\
// if this power is LOG_N + 1 or higher, the exponent of the polynomials is 0 and we have\n\
// fully reduced the polynomials, if power is  LOG_N or smaller, the depth\n\
// is equal to LOG_N + 1 - power\n\
`define INVERSE_N {pow(1<<(LOG_N-max(0, LOG_N - int(math.log2(math.gcd(2**LOG_N,modulus-1)))+1)),-1,modulus)} '
          f'//pow(N, -1, modulus) = pow(1<<LOG_N,-1,modulus)\n\
           ')

def generate_ntt_256_test():
    inputList = []
    N = 256
    random.seed(1)
    for i in range(N):
        inputList.append(random.randint(0, MODULUS-1))
    OutputNTT = NTT_with_params(inputList)
    input = open("NTT_IN_256.txt",'w')
    result = open("NTT_OUT_256.txt",'w')
    for i in range(N):
        input.write(hex(inputList[i])[2:] + "\n")
        result.write(hex(OutputNTT[i])[2:] + "\n")

def generate_poly_256_test():
    inputList = []
    N = 256
    random.seed(1)
    for i in range(N):
        inputList.append(random.randint(0, MODULUS-1))
    a = NTT_with_params(list(inputList))
    b = NTT_with_params(list(inputList))
    pointwise_out = pointwise_mult(a, b)
    d = INTT_with_params(list(pointwise_out))
    input = open("POLY_IN_256.txt",'w')
    result = open("POLY_OUT_256.txt",'w')
    for i in range(N):
        input.write(hex(inputList[i])[2:] + "\n")
        result.write(hex(d[i])[2:] + "\n")

def generate_intt_256_test():
    inputList = []
    N = 256
    random.seed(1)
    for i in range(N):
        inputList.append(random.randint(0, MODULUS-1))
    OutputNTT = INTT_with_params(inputList)
    input = open("INTT_IN_256.txt",'w')
    result = open("INTT_OUT_256.txt",'w')
    for i in range(N):
        input.write(hex(inputList[i])[2:] + "\n")
        result.write(hex(OutputNTT[i])[2:] + "\n")

if __name__ == '__main__':
    generate_ntt_parameters(3329, 8, 17)
    generate_kyber_test()
    #check_other_implementation()
    #generate_kyber_test()
    #generate_sample_test()
    #s = b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x07\xf8\x1a\x8b\x0e&j>\xe9-:c\xcd\xae\\\xff\x92\x19\x05TL\x9d\xd7\x97\xa8I\xe1\xd0T\x18\x0e\xca'
    #print(flip_hex_my_way(hexdigest(s)))
    #findBestParameters()
    #print(NAF(1259))
    #checkAllPossibillities()
    #generate_round_testvectors()
    #generate_round_testvectors_512()
    #generate_round_testvectors_shake256()
    #generate_round_testvectors_shake128()
    #generate_round_testvectors_shake256_stream_output()
    #print_testvector_round()
    """
    generate_ntt_parameters(3329, 8, 17)
    random.seed(1)
    inputList = [random.randint(0,MODULUS-1) for i in range(256)]
    #inputList = [0 for i in range(256)]
    #inputList[1] = 1

    original_list_0 = list(inputList)
    original_list_1 = list(inputList)
    a = NTT_with_params(original_list_0)
    b = NTT_done_by_Kyber_bitreversed_by_me(original_list_1)
    pointwise_out = pointwise_mult(a, b)
    # for i in range(len(b)):
    #     print(f"i: {i}, value: {a[i]}, value: {b[i]}")
    #generate_ntt_256_test()
    generate_intt_256_test()
    c = INTT_done_by_kyber_bitreversed_by_me(list(pointwise_out))
    d = INTT_with_params(list(pointwise_out))
    for i in range(len(b)):
             print(f"i: {i}, value: {d[i]}, value: {c[i]}")
    generate_poly_256_test()
    #generate_butterfly_test()
    """


