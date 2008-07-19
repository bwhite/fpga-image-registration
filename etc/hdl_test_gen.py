# Assumptions/Limitations/Unsupported/Conventions
# Assumptions/Limitations
# CLK exists and is posedge clocked
# RST exists and is active high
# Inputs are assumed irrelevent during RST assertion (though 2 resets can be used, one is with no asserted input and the other has asserted input)
# Only testing is done on posedge of clocks
# The module's RST is asserted before the first CT (this means that initial register values are not tested)
# Default register value is '0' for wires and (others => '0') for buses
# Test cases properly test the input space of the UUT, if not the the synthesis process may remove logic
# Generics that must be set are of 'integer' type (or equivelent)
# Don't cares are specified as X or x in place of the value, whether it is a bus or a wire, there is no way to specify individual bits of don't care for busses
# Spaces/tabs/blank lines can exist between required fields
# Comments are denoted by putting a pound "#" before each line that is a comment
# Since this module registers it's outputs, the true delay is one more than is specified in your module, this is corrected for automatically

# Conventions
# Internal signals are lower case (forced)
# External ports are upper case (forced)
# Port list is shown in the order of CLK,RST,input ports, output ports
# When tests are done, the unit under test is held in a reset state

# Input format for the following module
import re,math,os,sys,copy

def baseconv(number,fromdigits,todigits):
    if str(number)[0]=='-':
        number = str(number)[1:]
        neg=1
    else:
        neg=0

    # make an integer out of the number
    x=long(0)
    for digit in str(number):
        try:
            x = x*len(fromdigits) + fromdigits.index(digit)
        except ValueError:
            print("Baseconv: Character in input number not found in conversion table.")
            return None
    
    # create the result in base 'len(todigits)'
    res=""
    while x>0:
        digit = x % len(todigits)
        res = todigits[digit] + res
        x /= len(todigits)
    if neg:
        res = "-"+res
    return res

def to_bin(num,in_base,min_str_len=0,max_base=16):
    """
    >>> to_bin("100",16,10)
    '0100000000'
    >>> to_bin("256",10,10)
    '0100000000'
    >>> to_bin("400",8,10)
    '0100000000'
    >>> to_bin("2011",5,10)
    '0100000000'
    >>> to_bin("100111",3,10)
    '0100000000'
    >>> to_bin("100000000",2,10)
    '0100000000'

    >>> to_bin("F31",16,14)
    '00111100110001'
    >>> to_bin("3889",10,14)
    '00111100110001'
    >>> to_bin("7461",8,14)
    '00111100110001'
    >>> to_bin("111024",5,14)
    '00111100110001'
    >>> to_bin("12100001",3,14)
    '00111100110001'
    >>> to_bin("111100110001",2,14)
    '00111100110001'
    """
    if not isinstance(min_str_len,int):
        raise TypeError
    CONV_BASE = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    if len(CONV_BASE) < in_base or max_base < in_base:
        print("TO_BIN: Input base (%d) is larger than the maximum allowed (%d)!")%(in_base,min(max_base,len(CONV_BASE)))
        raise ValueError
    temp_str=baseconv(num,CONV_BASE[:in_base],CONV_BASE[:2])
    try:
        return '0'*(max(0,min_str_len-len(temp_str)))+temp_str
    except TypeError:
        return None

def _test():
    import doctest
    doctest.testmod()

def tab(num):
    return '  '*num

def next_valid_line(file_iter):
    """This function takes in a file iter and removes all of the comment lines, finally returning the first non-comment line"""
    re_comment=re.compile("^\\s*#")
    re_blank=re.compile("^\\s*$")
    cur_line=file_iter.next()
    while re_comment.search(cur_line) or re_blank.search(cur_line):
        cur_line=file_iter.next()
    return cur_line


def hdl_test_gen_factory(file_iter):
    """Takes in an iterator of lines parses out the relevent data"""
    # Initialize regex parsers
    re_start=re.compile("^\\s*/\\\\([A-Za-z0-9_]+)/\\\\") # Gives the tag name
    re_delay=re.compile("^\\s*DELAY:([0-9]+)") # Gives the number after the colon
    re_clk=re.compile("^\\s*CLK:([A-Za-z_]+)") # Gives the string after the colon
    re_rst=re.compile("^\\s*RST:([A-Za-z_]+)") # Gives the string after the colon
    re_const=re.compile("^\\s*CONST:\{((?:[A-Za-z0-9_,=])+)\}") # Gives the comma separated text, needs to be parsed further
    re_in=re.compile("^\\s*IN:\{((?:[A-Za-z0-9,_#\[\]])+)\}") # Gives the comma separated text, needs to be parsed further
    re_out=re.compile("^\\s*OUT:\{((?:[A-Za-z0-9,_#\[\]])+)\}") # Gives the comma separated text, needs to be parsed further
    re_reset_cmd=re.compile("^\\s*RESET") 
    re_ti=re.compile("^\\s*TI:\{((?:[A-Za-z0-9_,#\[\]])+)\}") # Gives the comma separated text, needs to be parsed further
    re_to=re.compile("^\\s*TO:\{((?:[A-Za-z0-9_,#\[\]])+)\}") # Gives the comma separated text, needs to be parsed further
    re_end=re.compile("^\\s*\\\\/([A-Za-z0-9_]+)\\\\/") # Gives the tag name

    # Search for test header and parse the static fields
    cur_line=next_valid_line(file_iter)
    try:
        while not re_start.search(cur_line):
            cur_line=next_valid_line(file_iter)
    except StopIteration:
        print('HDL Test Generator Factory: Test header not found!')
        return None

    module_name=re_start.search(cur_line).group(1)
    
    # Parse delay, clk, rst
    try:
        # Min value is 0, add one for input delay from state machine as the inputs to the UUT are registered!!
        module_delay=max(0,int(re_delay.search(next_valid_line(file_iter)).group(1))+1)
    except AttributeError:
        print('HDL Test Generator Factory: Module delay not found!')
        return None
    try:
        module_clk=re_clk.search(next_valid_line(file_iter)).group(1)
    except AttributeError:
        print('HDL Test Generator Factory: CLK specification not found!')
        return None
    try:
        module_rst=re_rst.search(next_valid_line(file_iter)).group(1)
    except AttributeError:
        print('HDL Test Generator Factory: RST specification not found!')
        return None

    # Parse const,in, out
    module_const=''
    try:
        cur_line=next_valid_line(file_iter)
        module_const=re_const.search(cur_line).group(1).split(',')
    except AttributeError: # The const line is optional!
        pass
    else:
        cur_line=next_valid_line(file_iter)
    try:
        module_in=re_in.search(cur_line).group(1).split(',')
    except AttributeError:
        print('HDL Test Generator Factory: IN specification not found! Found:'+cur_line)
        return None
    try:
        module_out=re_out.search(next_valid_line(file_iter)).group(1).split(',')
    except AttributeError:
        print('HDL Test Generator Factory: OUT specification not found!')
        return None

    # Parse TI/TO pairs and RESET (build test structure)
    module_tests=[]
    while 1:
        cur_line=next_valid_line(file_iter)
        if re_reset_cmd.search(cur_line): # Handle reset
            module_tests.append(None) # None signifies RESET
        elif re_ti.search(cur_line): # Handle TI/TO sequence
            try:
                temp_ti=re_ti.search(cur_line).group(1).split(',')
            except AttributeError:
                print('HDL Test Generator Factory: TI specification not found!')
                return None
            try:
                temp_to=re_to.search(next_valid_line(file_iter)).group(1).split(',')
            except AttributeError:
                print('HDL Test Generator Factory: TO specification not found!')
                return None
            module_tests.append([temp_ti,temp_to])
        else:
            break

    # Parse module footer
    if not re_end.search(cur_line) or re_end.search(cur_line).group(1) != module_name:
        print('HDL Test Generator Factory: Test footer not found!')
        return None
    
    # Create the hdl_test_gen class
    return hdl_test_gen(module_name,module_delay,module_clk,module_rst,module_const,module_in, module_out,module_tests)

class hdl_test_gen(object):
    def __init__(self, name, delay, clk, rst, const,input, output, tests):
        # Precompile regexs
        re_name=re.compile("([A-Za-z0-9_]+)")
        re_name_array=re.compile("([A-Za-z0-9_]+)\[([0-9]+)\]")
        re_num_base=re.compile("([0-9]+)#([0-9]+)#") # (base,number in base)
        re_num_eq=re.compile("([A-Za-z0-9_]+)=([0-9]+)") # (name,decimal number)
        # Copy over simple variables
        self.name=name
        self.delay=delay
        self.clk=clk.upper()
        self.rst=rst.upper()
        self.tests=tests
        self.uut_signal_pre = 'uut_'
        # Parse const/input/output
        self.test_num=None
        self.const=[] # Each constant entry in the form of ("Name",value)
        self.input=[] # Buses are '[name,size]' and wires are 'name'
        self.output=[]
        for const_iter in const:
            temp_const_re=re_num_eq.search(const_iter)
            self.const.append((temp_const_re.group(1),int(temp_const_re.group(2))))
        def port_parse(port_list,port): 
            for port_iter in port_list:
                try:
                    tmp_regex=re_name_array.search(port_iter)
                    port.append((tmp_regex.group(1).upper(),int(tmp_regex.group(2))))
                except AttributeError: # Not in nAmE_blaH[1923] format
                    try:
                        port.append(re_name.search(port_iter).group(1).upper())
                    except:
                        print('HDL Test Generator: Unexpected port format [%s], expected nAmE_blaH[1923] format!') % (port_iter)
                        continue
        port_parse(input,self.input)
        port_parse(output,self.output)

        # Parse tests to binary from their arbitrary bases
        def binarize_test_data(index,port,tests):
            for test in tests:
                try:
                    for test_port_ind in range(len(test[index])): # Input
                        # Test to see if this is a don't care value
                        if test[index][test_port_ind].upper() == 'X':
                            test[index][test_port_ind]='X'
                            continue
                        try:
                            tmp_regex=re_num_base.search(test[index][test_port_ind])
                            test[index][test_port_ind]=to_bin(tmp_regex.group(2),int(tmp_regex.group(1)), int(port[test_port_ind][1]))
                        except AttributeError:
                            try: # Try using default of decimal
                                test[index][test_port_ind]=to_bin(test[index][test_port_ind],10,int(port[test_port_ind][1]))
                            except AttributeError:
                                pass
                            except ValueError:
                                pass
                        # Make sure that wires only have '0' or '1' values
                        if isinstance(port[test_port_ind],str) and not (test[index][test_port_ind] == '1' or test[index][test_port_ind] == '0'):
                            print('HDL Test Generator: Wire %s has value %s, it must be binary!  Did you forget to specify the width (e.g., %s[5])?')%(port[test_port_ind],test[index][test_port_ind],port[test_port_ind])
                            raise AssertionError
                except TypeError:
                    continue
        
        binarize_test_data(0,self.input,self.tests)
        binarize_test_data(1,self.output,self.tests)

    def num_tests(self,end=None):
        return sum(map(lambda x: int(x != None), self.tests[0:end]))

    def fail_num_size(self):
        """This is the number of bits required to represent the number of tests"""
        return int(math.ceil(math.log(self.num_tests(),2)))

    def state_signal_size(self,test_dict=None):
        if test_dict==None:
            test_dict=self.__make_test_dict()
        # The number of bits to reprsent each state in the dict plus one end state
        return max(int(math.ceil(math.log(len(test_dict)+1,2))),0)

    def tb_name(self):
        if self.test_num != None:
            return self.name+'T'+str(self.test_num)+'_tb'
        else:
            return self.name+'_tb'

    def sim_name(self):
        if self.test_num != None:
            return self.name+'T'+str(self.test_num)+'_sim'
        else:
            return self.name+'_sim'

    def make_vhdl_tb(self):
        out_str=self.__make_header_comments()+self.__make_use_statements()+self.__make_entity()+self.__make_architecture()
        return out_str

    def make_vhdl_sim(self):
        out_str=self.__make_use_statements()+self.__make_sim_entity()+self.__make_sim_architecture()
        return out_str

    def set_test_num(self,test_num):
        self.test_num=test_num

    def __make_header_comments(self):
        return ''

    @staticmethod
    def __make_use_statements():
        return "LIBRARY ieee;\nUSE ieee.std_logic_1164.ALL;\nUSE ieee.numeric_std.ALL;\n"

    def __make_entity(self):
        out_str='ENTITY '+self.tb_name()+" IS\nPORT(\n"
        ports=(('CLK','IN',None),('RST','IN',None),('DONE','OUT',None),('FAIL','OUT',None),('FAIL_NUM','OUT',self.fail_num_size()))
        end_text='';
        for port in ports:
            out_str+=end_text # The first time this is called it will be a null string, every other time it is a semi-colon return
            end_text=';\n'
            out_str+=tab(1)+self.__make_port_def(port[0],port[1],port[2])
        return out_str+");\nEND "+self.tb_name()+';\n'

    def __make_sim_entity(self):
        return 'ENTITY '+self.sim_name()+" IS\nEND "+self.sim_name()+';\n'

    def __make_rst_logic(self):
        return tab(1)+'uut_rst_wire <= RST OR uut_rst;\n'

    def __make_architecture(self):
        out_str='ARCHITECTURE behavior OF %s IS\n' %(self.tb_name())
        out_str+=self.__make_uut_component()+self.__make_signals() # Generate section before BEGIN
        out_str+='BEGIN\n'
        out_str+=self.__make_rst_logic()
        out_str+=self.__make_uut_instance()
        out_str+=self.__make_test_process()
        out_str+='END;\n'
        return out_str

    def __make_sim_architecture(self):
        out_str='ARCHITECTURE behavior OF %s IS\n' %(self.sim_name())
        out_str+=self.__make_tb_component()+self.__make_sim_signals() # Generate section before BEGIN
        out_str+='BEGIN\n'
        out_str+=self.__make_tb_instance()
        out_str+=self.__make_sim_process()
        out_str+='END;\n'
        return out_str

    def __make_uut_component(self):
        out_str=tab(1)+'COMPONENT '+self.name+'\n'
        out_str+=self.__make_const()
        out_str+=tab(1)+'PORT(\n'
        def get_port_defs(ports,port_type):
            tmp_defs=''
            end_text=''
            for port in ports:
                tmp_defs+=end_text # The first time this is called it will be the input string, every other time it is a semi-colon return
                end_text=';\n'
                if isinstance(port,tuple):
                    tmp_defs += tab(2)+ self.__make_port_def(port[0],port_type,port[1])
                else:
                    tmp_defs += tab(2)+ self.__make_port_def(port,port_type)
            return tmp_defs
        out_str+=get_port_defs([self.clk,self.rst]+self.input,'IN')+';\n'+get_port_defs(self.output,'OUT')+');\n'+tab(1)+'END COMPONENT;\n'
        return out_str

    def __make_tb_component(self):
        out_str=tab(1)+'COMPONENT '+self.tb_name()+'\n'
        out_str+=tab(1)+'PORT(\n'
        def get_port_defs(ports,port_type):
            tmp_defs=''
            end_text=''
            for port in ports:
                tmp_defs+=end_text # The first time this is called it will be the input string, every other time it is a semi-colon return
                end_text=';\n'
                if isinstance(port,tuple):
                    tmp_defs += tab(2)+ self.__make_port_def(port[0],port_type,port[1])
                else:
                    tmp_defs += tab(2)+ self.__make_port_def(port,port_type)
            return tmp_defs
        out_str+=get_port_defs(['CLK','RST'],'IN')+';\n'+get_port_defs(['DONE','FAIL',('FAIL_NUM',self.fail_num_size())],'OUT')+');\n'+tab(1)+'END COMPONENT;\n'
        return out_str

    def __make_const(self):
        out_str=''
        end_text=''
        if len(self.const) > 0:
            out_str+=tab(1)+'GENERIC('
            for const in self.const:
                out_str+=end_text
                end_text=';'
                out_str+='\n'+tab(2)+self.__make_const_def(const[0],const[1])
            out_str+=');\n'
        return out_str

    @staticmethod
    def __make_const_def(name,value):
        """
        >>> hdl_test_gen._hdl_test_gen__make_const_def('ADDr_BItS',8)
        'ADDR_BITS : integer := 8'
        """
        return '%s : integer := %d' % (name.upper(),value)

    @staticmethod
    def __make_port_def(port_name, port_type,size=None):
        """
        >>> hdl_test_gen._hdl_test_gen__make_port_def('CLK','IN',None)
        'CLK : IN STD_LOGIC'
        >>> hdl_test_gen._hdl_test_gen__make_port_def('BUS','OUT',5)
        'BUS : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)'
        """
        if size == None:
            return "%s : %s STD_LOGIC" % (port_name,port_type);
        else:
            return "%s : %s STD_LOGIC_VECTOR(%d DOWNTO 0)" % (port_name,port_type,size-1);

    def __make_state_signal(self,len_test_dict=None):
        if len_test_dict==None:
            len_test_dict=len(self.__make_test_dict())
        return tab(1)+'SIGNAL state : STD_LOGIC_VECTOR(%d DOWNTO 0);\n'%(self.state_signal_size()-1)

    def __make_signals(self):
        out_str=tab(1)+'SIGNAL uut_rst_wire, uut_rst : STD_LOGIC;\n'+self.__make_state_signal()
        if len(self.input) >0:
            out_str+=tab(1)+'-- UUT Input\n'
        # Generate input signals
        return out_str+self.generate_signals(self.add_prefix(self.input))+tab(1)+'-- UUT Output\n'+self.generate_signals(self.add_prefix(self.output))

    def add_prefix(self,ports):
        ports=copy.deepcopy(ports)
        for port_ind in range(len(ports)):
            if isinstance(ports[port_ind],tuple):
                ports[port_ind]=(self.uut_signal_pre+ports[port_ind][0],ports[port_ind][1])
            else:
                ports[port_ind]=self.uut_signal_pre+ports[port_ind]
        return ports

    @staticmethod
    def generate_signals(ports):
        vector_dict={}
        wire_list=[]
        out_str=''
        for port in ports:
            if isinstance(port,tuple):
                try:
                    vector_dict[port[1]].append(port[0].lower())
                except KeyError:
                    vector_dict[port[1]]=[port[0].lower()]
            else:
                wire_list.append(port.lower())
        # Output wires
        if len(wire_list) != 0:
            out_str+=tab(1)+'SIGNAL '+reduce(lambda x,y:x+', '+y,wire_list)+' : STD_LOGIC;\n'
        # Output buses
        for bus_size in vector_dict.iterkeys():
            out_str+=tab(1)+'SIGNAL '+reduce(lambda x,y:x+', '+y,vector_dict[bus_size])+' : STD_LOGIC_VECTOR(%d DOWNTO 0);\n'%(bus_size-1)
        return out_str

    def __make_sim_signals(self):
        out_str=tab(1)+"SIGNAL CLK : STD_LOGIC := '0';\n"+tab(1)+"SIGNAL RST : STD_LOGIC := '1';\n"
        return out_str+self.generate_signals(['DONE','FAIL',('FAIL_NUM',self.fail_num_size())])

    def __make_uut_instance(self):
        out_str=tab(1)+'uut :  '+ self.name+' PORT MAP (\n'
        # CLK and RST
        out_str += tab(2)+self.clk+' => CLK,\n'+tab(2)+self.rst+' => uut_rst_wire'
        # IN and OUT
        for port in self.input+self.output:
            out_str+=',\n'
            if isinstance(port,tuple):
                out_str+=tab(2) + port[0] + ' => ' + self.uut_signal_pre+port[0].lower()
            else:
                out_str+=tab(2) + port + ' => ' + self.uut_signal_pre+port.lower()
        return out_str+'\n'+tab(1)+');\n'

    def __make_tb_instance(self):
        out_str=tab(1)+'uut :  '+ self.tb_name()+' PORT MAP (\n'
        # CLK and RST
        out_str += tab(2)+'CLK'+' => clk,\n'+tab(2)+'RST'+' => rst'
        # IN and OUT
        
        for port in ['DONE','FAIL','FAIL_NUM']:
            out_str+=',\n'
            if isinstance(port,tuple):
                out_str+=tab(2) + port[0] + ' => ' + port[0].lower()
            else:
                out_str+=tab(2) + port + ' => ' + port.lower()
        return out_str+'\n'+tab(1)+');\n'

    def __make_test_process(self,test_dict=None):
        if test_dict==None:
            test_dict=self.__make_test_dict()
        out_str=tab(1)+"PROCESS (CLK) IS\n"+tab(1)+"BEGIN\n"+tab(2)+"IF CLK'event AND CLK='1' THEN\n"+tab(3)+"IF RST='1' THEN\n"
        out_str+=self.__make_rst_state()+tab(3)+'ELSE\n'+tab(4)+'CASE state IS\n'
        # Make states
        for state in range(len(test_dict)):
            out_str+=self.__make_state(state,test_dict)
        out_str+=tab(5)+'WHEN OTHERS =>\n'
        out_str+=self.__make_wire_assignment('DONE',6,'1')+'\n'
        out_str+=self.__make_wire_assignment('uut_rst',6,'1')+'\n'
        out_str+=tab(4)+'END CASE;\n'+tab(3)+'END IF;\n'+tab(2)+'END IF;\n'+tab(1)+'END PROCESS;\n'
        return out_str

    def __make_sim_process(self):
        out_str=tab(1)+"PROCESS\n"+tab(1)+"BEGIN\n"
        out_str+=reduce(lambda x,y: x+y,map(lambda x: tab(2)+"CLK <= '%d';\n"%(x)+tab(2)+"WAIT FOR 5ns;\n",[0,1,0,1]))
        out_str+=tab(2)+"RST <= '0';\n"
        out_str+=tab(1)+'END PROCESS;\n'
        return out_str

    def __make_state(self,clock_time,test_dict=None):
        if test_dict==None:
            test_dict=self.__make_test_dict()
        out_str=tab(5)+'WHEN "%s" =>\n' % (to_bin(str(clock_time),10,self.state_signal_size(test_dict)))
        # Output driving signals
        try:
            for input_iter in range(len(test_dict[clock_time][0])):
                tmp_input=test_dict[clock_time][0][input_iter]
                if isinstance(self.input[input_iter],tuple):
                    out_str+=self.__make_bus_assignment(self.uut_signal_pre+self.input[input_iter][0].lower(),6,tmp_input)+'\n'
                else:
                    out_str+=self.__make_wire_assignment(self.uut_signal_pre+self.input[input_iter].lower(),6,tmp_input)+'\n'
        except TypeError: # If there is no input drivers than don't output anything for them
            pass
        except KeyError: # If there are no test requirements for this CT
            pass

        # Test input signals (output from uut)
        end_text=tab(6)+'IF '
        values_tested=False # This is used to correct for the case where we do have test values, but they are all "don't cares"
        try:
            for output_iter in range(len(test_dict[clock_time][1])):
                output=test_dict[clock_time][1][output_iter]
                if output == 'X':
                    continue
                values_tested=True
                out_str+=end_text
                end_text=' OR '
                if isinstance(self.output[output_iter],tuple):
                    out_str+=self.__test_notequals_bus(self.uut_signal_pre+self.output[output_iter][0].lower(),0,output)
                else:
                    out_str+=self.__test_notequals_wire(self.uut_signal_pre+self.output[output_iter].lower(),0,output)
        except KeyError: # If there are no test requirements for this CT
            out_str+=self.__make_bus_assignment('state',6,to_bin(str(clock_time+1),10,self.state_signal_size(test_dict)))+'\n'
        except TypeError: # If there is no input signals then put in the default state increment
            out_str+=self.__make_bus_assignment('state',6,to_bin(str(clock_time+1),10,self.state_signal_size(test_dict)))+'\n'
        else:
            if values_tested:
                out_str+=' THEN\n'
                out_str+=self.__make_wire_assignment('FAIL',7,'1')+'\n'
                out_str+=self.__make_bus_assignment('FAIL_NUM',7,to_bin(str(test_dict[clock_time][2]),10,self.fail_num_size()))+'\n'
                out_str+=self.__make_bus_assignment('state',7,to_bin(str(len(test_dict)),10,self.state_signal_size(test_dict)))+'\n'
                out_str+=tab(6)+'ELSE\n'
                out_str+=self.__make_bus_assignment('state',7,to_bin(str(clock_time+1),10,self.state_signal_size(test_dict)))+'\n'
                out_str+=tab(6)+'END IF;\n'
            else:
                out_str+=self.__make_bus_assignment('state',6,to_bin(str(clock_time+1),10,self.state_signal_size(test_dict)))+'\n'
        # Set reset signal
        try:
            if test_dict[clock_time]==None:
                out_str+=self.__make_wire_assignment('uut_rst',6,'1')+'\n'
            else:
                out_str+=self.__make_wire_assignment('uut_rst',6,'0')+'\n'
        except KeyError: # If there are no test requirements for this CT
            out_str+=self.__make_wire_assignment('uut_rst',6,'0')+'\n'

        return out_str

    @staticmethod
    def __test_notequals_wire(name,tab_level,value):
        """
        >>> hdl_test_gen._hdl_test_gen__test_notequals_wire('a',0,'1')
        "a /= '1'"
        """
        return tab(tab_level)+name+" /= '"+value+"'"
    @staticmethod
    def __test_notequals_bus(name,tab_level,value):
        """
        >>> hdl_test_gen._hdl_test_gen__test_notequals_bus('a',0,'1001')
        'a /= "1001"'
        """
        return tab(tab_level)+name+' /= "'+value+'"'
    def __make_rst_state(self):
        wire_list=map(lambda x:self.__make_wire_assignment(x,4)+'\n',['DONE','FAIL','uut_rst'])
        bus_list=map(lambda x:self.__make_bus_assignment(x,4)+'\n',['FAIL_NUM','state'])
        return reduce(lambda x,y: x+y, wire_list+bus_list)

    @staticmethod
    def __make_wire_assignment(name,tab_level=0,value='0'):
        """
        >>> hdl_test_gen._hdl_test_gen__make_wire_assignment('a')
        "a <= '0';"
        >>> hdl_test_gen._hdl_test_gen__make_wire_assignment('a',0,'1')
        "a <= '1';"
        """
        return tab(tab_level)+name+" <= '%s';"%(value)

    @staticmethod
    def __make_bus_assignment(name,tab_level=0,value="(OTHERS => '0')"):
        """
        >>> hdl_test_gen._hdl_test_gen__make_bus_assignment('a')
        "a <= (OTHERS => '0');"
        >>> hdl_test_gen._hdl_test_gen__make_bus_assignment('a',0,"(OTHERS=>'1')")
        "a <= (OTHERS=>'1');"
        >>> hdl_test_gen._hdl_test_gen__make_bus_assignment('a',0,"(5 DOWNTO 1  => '1')")
        "a <= (5 DOWNTO 1  => '1');"
        >>> hdl_test_gen._hdl_test_gen__make_bus_assignment('a',0,"100")
        'a <= "100";'
        """
        aggregate_test=re.compile("(?i)\\([a-z0-9\\s]+=\\>\\s*'[0-1]'\\)")
        if aggregate_test.search(value):
            return tab(tab_level)+name+" <= %s;"%(value)
        else:
            return tab(tab_level)+name+' <= "%s";'%(value)

    def __make_test_dict(self):
        test_dict={}
        cur_ct=0
        for test_num in range(len(self.tests)):
            test=self.tests[test_num]
            try:
                test_dict[cur_ct][0]=test[0]
            except KeyError: # New entry
                test_dict[cur_ct]=[test[0],None,None]
            except TypeError: # RESET
                try:
                    rst_ct=max(test_dict.iterkeys())+1
                except ValueError: # First entry
                    rst_ct=0
                test_dict[rst_ct]=None
                cur_ct=rst_ct+1
                continue
            try:
                test_dict[cur_ct+self.delay][1]=test[1]
            except KeyError: # New entry
                test_dict[cur_ct+self.delay]=[None,test[1],self.num_tests(cur_ct+1)-1]
            cur_ct+=1
        return test_dict

if __name__ == "__main__":
    _test()
    try:
        path=sys.argv[1]
    except IndexError:
        raise Exception,'Usage "python %s <test_root_directory>"'%(sys.argv[0])
    for root,dirs, files in os.walk(path):
        test_sets={} # Stored as module_name:[test_references]
        for cur_file in files:
            if cur_file[-5:]=='.hdlt':
                print('Generating tests for [%s]')%(root+'/'+cur_file)
                cur_test_file=open(root+'/'+cur_file,'r')
                hdlt_gen=hdl_test_gen_factory(cur_test_file)
                cur_test_file.close()
                try:
                    test_sets[root+'/'+hdlt_gen.name].append(hdlt_gen)
                except KeyError:
                    test_sets[root+'/'+hdlt_gen.name]=[hdlt_gen]
        for tested_module in test_sets.iterkeys():
            for test_num in range(len(test_sets[tested_module])):
                test_name=tested_module+'T'+str(test_num)
                test_sets[tested_module][test_num].set_test_num(test_num)
                print('Saving test bench [%s]')%(test_name+'_tb.vhd')
                tb_file=open(test_name+'_tb.vhd','w')
                tb_file.write(test_sets[tested_module][test_num].make_vhdl_tb())
                tb_file.close()
                print('Saving simulation stub [%s]')%(test_name+'_sim.vhd')
                sim_file=open(test_name+'_sim.vhd','w')
                sim_file.write(test_sets[tested_module][test_num].make_vhdl_sim())
                sim_file.close()
