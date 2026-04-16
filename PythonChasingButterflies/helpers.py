import random
import math
N = 256
MODULUS = 3329

TWIDDLE_2N = 17 # sage: get_omega_goldilocks(12)
TWIDDLE_N = pow(TWIDDLE_2N,2, MODULUS) # sage: get_omega_goldilocks(12)
INVERSE_TWIDDLE_2N = pow(TWIDDLE_2N, -1, MODULUS)
INVERSE_TWIDDLE_N = pow(INVERSE_TWIDDLE_2N, 2, MODULUS)

#K_INVERSE = pow(13, -1, MODULUS)
inv_N = pow(128, -1 , MODULUS)
INCOMPLETE_STAGE=1




def butterfly_GS(input_a, input_b, twiddle):
    return [((input_a + input_b))%MODULUS,((input_a - input_b)*twiddle)%MODULUS]


def butterfly_CT(input_a, input_b, twiddle):
    return [((input_a + input_b*twiddle))%MODULUS,((input_a - input_b*twiddle))%MODULUS]

def intReverse(a,n):
    b = ('{:0'+str(n)+'b}').format(a) # "{0:b} means print in binary
    return int(b[::-1],2)

# Bit-Reversed index
def indexReverse(a,r):
    n = len(a)
    b = [0]*n
    for i in range(n):
        rev_idx = intReverse(i,r)
        b[rev_idx] = a[i]
    return b
# Bit-Reversed index for our Kyber implementation,
# because frankly it doesn't matter how it comes out exactly as long as
# no extra logic is required to fix it (which there isn't)
# and the kyber spec result is index bitreversed anyway
def specialIndexReverse(a_list,LOG_N,reduced_polynomial_depth):
    n = len(a_list)
    b = [0]*n
    for i in range(n):
        rev_idx = intReverse(i>>reduced_polynomial_depth,LOG_N-reduced_polynomial_depth)
        b[(rev_idx<<reduced_polynomial_depth)+i%(1<<reduced_polynomial_depth)] = a_list[i]
    return b


def index_bit_reverse(arrayIn):
    N = len(arrayIn)
    v = int(math.log(N, 2))
    return indexReverse(list(arrayIn), v)


def modinv(a, m):
    g, x, y = egcd(a, m)
    if g != 1:
        raise Exception('Modular inverse does not exist')
    else:
        return x % m

def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)


def ntt_N_HW_with_CoefPerClockCycle_optimized(input_in, CoefPerClockCycle = 1 << 6):
    N = len(input_in)
    ClocksPerData = N//CoefPerClockCycle
    A = []
    B = []
    C = []
    D = []
    result_array = N*[0]
    for i in range(CoefPerClockCycle):
        A.append(ClocksPerData*[0])
        D.append(ClocksPerData*[0])
    for i in range(ClocksPerData):
        B.append(CoefPerClockCycle*[0])
        C.append(CoefPerClockCycle*[0])
    for i in range(CoefPerClockCycle):
        for j in range(ClocksPerData):
            A[i][j] =  input_in[ClocksPerData*i+j]

    matrix_transpose_from_CoefPerClockCycle_to_ClocksPerData_rows(A,B, CoefPerClockCycle, ClocksPerData)


    for i in range(ClocksPerData):
        temp = IterativeForwardNTT_pass_2(B[i], MODULUS, pow(TWIDDLE_N,ClocksPerData,MODULUS),pow(TWIDDLE_2N,ClocksPerData,MODULUS))
        b = index_bit_reverse(temp)
        twiddle_exponent = [i*j for j in range(CoefPerClockCycle)]
        twiddles = [pow(TWIDDLE_N, exponent, MODULUS) for exponent in twiddle_exponent]
        elementwise_mult= [(b[j] * twiddles[j] * pow(TWIDDLE_2N ,i,MODULUS)) % MODULUS for j in range(CoefPerClockCycle)]
        C[i] = list(elementwise_mult)
    matrix_transpose_from_ClocksPerData_to_CoefPerClockCycle_rows(C,A, CoefPerClockCycle, ClocksPerData)

    for i in range(CoefPerClockCycle):
        #for j in range(32):
        #    B[i][j] = B[i][j] * (TWIDDLE_2N**j)
        fourier_list = index_bit_reverse(IterativeForwardNTT_pass_2(A[i], MODULUS, pow(TWIDDLE_N,CoefPerClockCycle,MODULUS),1))
        result_list_ClocksPerData_elements= [(fourier_list_element)%MODULUS for fourier_list_element in fourier_list]
        D[i] = list(result_list_ClocksPerData_elements)


    matrix_transpose_from_CoefPerClockCycle_to_ClocksPerData_rows(D,B, CoefPerClockCycle, ClocksPerData)
    for i in range(ClocksPerData):
        for j in range(CoefPerClockCycle):
            result_array[CoefPerClockCycle*i+j] =  B[i][j]

    return result_array

def intt_N_HW_with_CoefPerClockCycle_optimized(input_in, CoefPerClockCycle = 1 << 6):
    N = len(input_in)
    ClocksPerData = N//CoefPerClockCycle
    A = []
    B = []
    C = []
    D = []
    result_array = N*[0]
    for i in range(CoefPerClockCycle):
        A.append(ClocksPerData*[0])
        D.append(ClocksPerData*[0])
    for i in range(ClocksPerData):
        B.append(CoefPerClockCycle*[0])
        C.append(CoefPerClockCycle*[0])
    for i in range(CoefPerClockCycle):
        for j in range(ClocksPerData):
            A[i][j] =  input_in[ClocksPerData*i+j]

    matrix_transpose_from_CoefPerClockCycle_to_ClocksPerData_rows(A,B, CoefPerClockCycle, ClocksPerData)


    for i in range(ClocksPerData):
        temp = IterativeInverseNTT_pass_2(B[i], MODULUS, pow(INVERSE_TWIDDLE_N,ClocksPerData,MODULUS),1)
        b = index_bit_reverse(temp)
        twiddle_exponent = [i*j for j in range(CoefPerClockCycle)]
        twiddles = [inv_N*pow(INVERSE_TWIDDLE_N, exponent, MODULUS) for exponent in twiddle_exponent]
        elementwise_mult= [(b[j] * twiddles[j] * pow(INVERSE_TWIDDLE_2N,j,MODULUS)) % MODULUS for j in range(CoefPerClockCycle)]
        C[i] = list(elementwise_mult)
    matrix_transpose_from_ClocksPerData_to_CoefPerClockCycle_rows(C,A, CoefPerClockCycle, ClocksPerData)

    for i in range(CoefPerClockCycle):
        fourier_list = index_bit_reverse(IterativeInverseNTT_pass_2(A[i], MODULUS,
                                                                    pow(INVERSE_TWIDDLE_N, CoefPerClockCycle,MODULUS),
                                                                    pow(INVERSE_TWIDDLE_2N,CoefPerClockCycle,MODULUS)))
        result_list_ClocksPerData_elements= [(fourier_list_element)%MODULUS for fourier_list_element in fourier_list]
        D[i] = list(result_list_ClocksPerData_elements)


    matrix_transpose_from_CoefPerClockCycle_to_ClocksPerData_rows(D,B, CoefPerClockCycle, ClocksPerData)
    for i in range(ClocksPerData):
        for j in range(CoefPerClockCycle):
            result_array[CoefPerClockCycle*i+j] =  B[i][j]

    return result_array


def IterativeForwardNTT_pass_2(arrayIn, P, W, psi):
    arrayOut = [0] * len(arrayIn)
    N = len(arrayIn)
    for idx in range(N):
        arrayOut[idx] = arrayIn[idx]
    v = int(math.log(N, 2))
    for i in range(0, v):
        #print("Stage", i)

        for j in range(0, (2 ** i)):
            for k in range(0, (2 ** (v - i - 1))):
                s = j * (2 ** (v - i)) + k
                t = s + (2 ** (v - i - 1))

                psi_part = pow(psi, 2 ** (v - i-1), P)
                omega_part = pow(W, intReverse(j, v-1), P)
                as_temp = arrayOut[s]
                at_temp = arrayOut[t] * psi_part * omega_part

                arrayOut[s] = (as_temp + at_temp) % P
                arrayOut[t] = ((as_temp - at_temp) ) % P
    return arrayOut

def IterativeInverseNTT_pass_2(arrayIn, P, W, psi):
    arrayOut = [0] * len(arrayIn)
    N = len(arrayIn)
    for idx in range(N):
        arrayOut[idx] = arrayIn[idx]
    v = int(math.log(N, 2))
    for i in range(0, v):
        #print("Stage", i)

        for j in range(0, (2 ** i)):
            for k in range(0, (2 ** (v - i - 1))):
                s = j * (2 ** (v - i)) + k
                t = s + (2 ** (v - i - 1))

                psi_part = pow(psi, 2 ** i, P)
                omega_part = pow(W, k * 2 ** i, P)
                w= psi_part * omega_part
                as_temp = arrayOut[s]
                at_temp = arrayOut[t]

                arrayOut[s] = (as_temp + at_temp) % P
                arrayOut[t] = ((as_temp - at_temp) * w) % P

    return arrayOut



def matrix_transpose_from_CoefPerClockCycle_to_ClocksPerData_rows(A, B, CoefPerClockCycle, ClocksPerData):
    for i in range(ClocksPerData):
        for j in range(CoefPerClockCycle):
            B[i][j] =  A[j][i]
    return B

def matrix_transpose_from_ClocksPerData_to_CoefPerClockCycle_rows(A, B, CoefPerClockCycle, ClocksPerData):
    for i in range(CoefPerClockCycle):
        for j in range(ClocksPerData):
            B[i][j] =  A[j][i]
    return B

def IterativeForwardNTT_pass_2_MODDED(arrayIn, P, W, psi):
    arrayOut = [0] * len(arrayIn)
    N = len(arrayIn)
    for idx in range(N):
        arrayOut[idx] = arrayIn[idx]
    v = int(math.log(N, 2))
    V_MODDED = v-1
    for i in range(0, V_MODDED):
        #print("Stage", i)

        for j in range(0, (2 ** i)):
            for k in range(0, (2 ** (v - i - 1))):
                s = j * (2 ** (v - i)) + k
                t = s + (2 ** (v - i - 1))

                psi_part = pow(psi, 2 ** (V_MODDED - i-1), P)
                omega_part = pow(W, intReverse(j, V_MODDED-1), P)
                zeta = psi_part*omega_part%P
                as_temp = arrayOut[s]
                at_temp = arrayOut[t] * zeta

                arrayOut[s] = (as_temp + at_temp) % P
                arrayOut[t] = ((as_temp - at_temp) ) % P
    return arrayOut

def NTT_with_params(arrayIn):
    arrayAdjusted = []
    arrayAdjusted_out = []
    arrayOut = len(arrayIn)*[0]
    number_of_ntts = (1<<INCOMPLETE_STAGE)
    data_per_ntt = N//(1<<INCOMPLETE_STAGE)
    for i in range(number_of_ntts):
        arrayAdjusted.append(data_per_ntt*[0])
        arrayAdjusted_out.append(data_per_ntt*[0])
    for j in range(data_per_ntt):
        for i in range(number_of_ntts):
            arrayAdjusted[i][j] = arrayIn[j*number_of_ntts+i]
    for i in range(number_of_ntts):
        arrayAdjusted_out[i] = ntt_N_HW_with_CoefPerClockCycle_optimized(arrayAdjusted[i])
    for j in range(data_per_ntt):
        for i in range(number_of_ntts):
            arrayOut[j*number_of_ntts+i] = arrayAdjusted_out[i][j]
    return arrayOut

def INTT_with_params(arrayIn):
    arrayAdjusted = []
    arrayAdjusted_out = []
    arrayOut = len(arrayIn)*[0]
    number_of_ntts = (1<<INCOMPLETE_STAGE)
    data_per_ntt = N//(1<<INCOMPLETE_STAGE)
    for i in range(number_of_ntts):
        arrayAdjusted.append(data_per_ntt*[0])
        arrayAdjusted_out.append(data_per_ntt*[0])
    for j in range(data_per_ntt):
        for i in range(number_of_ntts):
            arrayAdjusted[i][j] = arrayIn[j*number_of_ntts+i]
    for i in range(number_of_ntts):
        arrayAdjusted_out[i] = intt_N_HW_with_CoefPerClockCycle_optimized(arrayAdjusted[i])
    for j in range(data_per_ntt):
        for i in range(number_of_ntts):
            arrayOut[j*number_of_ntts+i] = arrayAdjusted_out[i][j]
    return arrayOut

def NTT_done_by_Kyber_bitreversed_by_me(arrayIn):
    return specialIndexReverse(NTT_as_done_by_kyber(list(arrayIn)), 8, 1)
def INTT_done_by_kyber_bitreversed_by_me(arrayIn):
    return INTT_as_done_by_kyber(specialIndexReverse(list(arrayIn), 8, 1))


def NAF(E):
    i = 0
    z = []
    while E > 0:
        if E%2==1:
            z.append(int(2 - (E % 4)))
        else:
            z.append(0)
        E = (E - int(z[i]))/2
        i = i + 1
    return z[::-1]

def NTT_as_done_by_kyber(arrayIn):
    zetas = [
        pow(TWIDDLE_2N,  intReverse(i, 7), 3329) for i in range(128)
    ]
    k, l = 1, 128
    j = 0
    coeffs = arrayIn
    while l >= 2:
        start = 0
        while start < 256:
            zeta = zetas[k]
            k = k + 1
            for j in range(start, start + l):
                t = zeta * coeffs[j + l]
                coeffs[j + l] = coeffs[j] - t
                coeffs[j] = coeffs[j] + t
            start = l + (j + 1)
        l = l >> 1

    for j in range(256):
        coeffs[j] = coeffs[j] % 3329
    return coeffs

def INTT_as_done_by_kyber(arrayIn):
    zetas = [
        pow(TWIDDLE_2N,  intReverse(i, 7), 3329) for i in range(128)
    ]
    l, l_upper = 2, 128
    k = l_upper - 1
    coeffs = arrayIn
    while l <= 128:
        start = 0
        while start < 256:
            zeta = zetas[k]
            k = k - 1
            j = start
            for j in range(start, start + l):
                t = coeffs[j]
                coeffs[j] = t + coeffs[j + l]
                coeffs[j + l] = coeffs[j + l] - t
                coeffs[j + l] = zeta * coeffs[j + l]
            start = j + l + 1
        l = l << 1

    for j in range(256):
        coeffs[j] = (coeffs[j] * inv_N) % 3329


    return coeffs

def checkAllPossibillities():
    COMPRESS = 10
    FIXED_BITS = 22
    resultList = []
    #print((2**(COMPRESS)/MODULUS)*2079)
    print(int(2**(FIXED_BITS)/MODULUS) )
    for i in range(MODULUS):
        verilog = round((2**(COMPRESS+FIXED_BITS)/MODULUS)*(i)/(2**FIXED_BITS))
        #verilog_better =(10321340 * (i<<10) + 17171611648)>>35

        a = (int(2**(FIXED_BITS)/MODULUS) *(((i)<<COMPRESS)+ (MODULUS//2))  )>>FIXED_BITS
        r = ((i<<COMPRESS)+(MODULUS//2))-a*MODULUS
        if (r>=MODULUS):
            verilog_better = a+1
        else:
            verilog_better = a
        correct = round((2**(COMPRESS)/MODULUS)*i)

        if verilog_better != correct:
            print(i, verilog_better, correct)

def findBestParameters(): # see Drane and Cheung 2012 Correctly Rounded Constant Integer Division via Multiply-Add
    d = MODULUS
    n = 22
    X_plus = d*((2**(n+1)-d-1)//(2*d)) -1
    X_minus = d*((2**(n+1)-d-1)//(2*d)) -1
    k_plus = 1
    while (2**k_plus/((-2**k_plus)%d)<= X_plus):
        k_plus+=1
    k_minus = 1
    while (2**k_minus/((2**k_minus)%d)<= X_minus):
        k_minus+=1
    print("Ks and Xs:", k_plus, k_minus, X_plus, X_minus)
    print("k_plus wins") #If you want to see the k_minus case, go look at the paper,
    # This is already way more optimization than this compress function deserves, Ahmdahl's law etc...

    a_plus = 2**k_plus//d + 1
    Y_plus_k = a_plus*(d-1)//2 +(2**k_plus-a_plus*d)
    Y_plus_a = a_plus*(d-1)//2 + (2**k_plus-a_plus*d)*(((2**(n+1)-d-1)//(2*d))-1)
    print(Y_plus_a, Y_plus_k)
    b = min([x for x in range(Y_plus_a,Y_plus_k+1)], key=hamming_count)
    print(a_plus, b, bin(b))
    ## FFS it doesn't work.... break for x = 2079, Whelp 4 hours I'm never getting back.
    # Don't use Drane and Cheung 2012


def hamming_count(x):
    return bin(x).count("1")

def ntt_sample(input_bytes):
    """
    Algorithm 1 (Parse)
    https://pq-crystals.org/kyber/data/kyber-specification-round3-20210804.pdf

    Algorithm 6 (Sample NTT)

    Parse: B^* -> R
    """
    i, j = 0, 0
    coefficients = [0 for _ in range(N)]
    while j < N:
        d1 = input_bytes[i] + 256 * (input_bytes[i + 1] % 16)
        d2 = (input_bytes[i + 1] // 16) + 16 * input_bytes[i + 2]

        if d1 < 3329:
            coefficients[j] = d1
            j = j + 1

        if d2 < 3329 and j < N:
            coefficients[j] = d2
            j = j + 1

        i = i + 3
    return coefficients

def pointwise_mult(a,b):
    c = [0]*len(a)
    for i in range(len(a)//2):
        c[2*i], c[2*i+1] = coefficient_multiplication(a[2*i], a[2*i+1], b[2*i], b[2*i+1], pow(TWIDDLE_2N,  2*i+1, 3329))
    return c

def coefficient_multiplication(a0, a1, b0, b1, zeta):
    """
    Credit to Giacomo Pope
    """
    r0 = (a0 * b0 + zeta * a1 * b1) % 3329
    r1 = (a1 * b0 + a0 * b1) % 3329
    return r0, r1

def generate_butterfly_test():
    input_a_python = open("input_a.txt", "w")
    input_b_python = open("input_b.txt", "w")
    result_a = open("result_a.txt",'w')
    result_b = open("result_b.txt",'w')
    #input_a = random.randint(0, 2**96+1-1)
    #input_b = random.randint(0, 2**96+1-1)
    input_a = [0, 1, 2**63, 0 , 2**64-2**32, 2**64-2**32-1, 2,  4,    8,      2**63-2**31,    2**63-2**31-1, 2**63-2**31, 2**63-2**31  , 2**63-2**31+1, 2**63-2**31//2, 2**63-2**31]
    input_b = [0, 0, 0, 1 , 2**64-2**32, 2**64-2**32,  2-1, 4//2, 8//2-1, 2**63-2**31//2, 2**63-2**31,   2**63-2**31, 2**63-2**31+1, 2**63-2**31  , 2**63-2**31 +1, 2**63-2**31 - 1]
    for i in range(len(input_a)):
        input_a[i] = input_a[i]% MODULUS
        input_b[i] = input_b[i]% MODULUS
        input_a_python.write(hex(input_a[i])[2:] + "\n")
        input_b_python.write(hex(input_b[i])[2:] + "\n")
        for shift_index in range(256):
            [output_a, output_b] = butterfly_CT(input_a[i], input_b[i], (3073*pow(17,shift_index,MODULUS))%MODULUS)
            result_a.write(hex(output_a)[2:] + "\n")
            result_b.write(hex(output_b)[2:] + "\n")

