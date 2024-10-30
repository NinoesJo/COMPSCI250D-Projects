import java.io.*;
import java.util.*;

class CacheBlock {
    boolean valid;
    boolean dirty;
    int tag;
    String[] data;
    int counter;

    public CacheBlock(int blockSize) {
        valid = false;
        dirty = false;
        tag = -1;
        data = new String[blockSize];
        Arrays.fill(data, "00");
        counter = 0;
    }
}

public class cachesim {

    // does logorithm base 2
    public static int log2(int x) {
        int result = 0;
        while (x > 1) {
            x >>= 1;
            result++;
        }
        return result;
    }


    // finds the index for the lru
    public static int lruSearcher(CacheBlock[][] cache, int setIndex, int associativity) {
        int lruIndex = 0;
        int lruCounter = Integer.MAX_VALUE;
        for (int i = 0; i < associativity; i++) {
            if (cache[setIndex][i].valid && cache[setIndex][i].counter < lruCounter) {
                lruIndex = i;
                lruCounter = cache[setIndex][i].counter;
            }
        }
        return lruIndex;
    }

    // it updates the lru after scanning each line
    public static void lruChange(CacheBlock[][] cache, int setIndex, int accessedIndex, int associativity) {
        for (int i = 0; i < associativity; i++) {
            if (cache[setIndex][i].valid) {
                if (i == accessedIndex) {
                    cache[setIndex][i].counter = 0;
                } else {
                    cache[setIndex][i].counter++;
                }
            }
        }
    }

    public static void storeWord(int address, int accessSize, String[] data, CacheBlock[][] cache, String[] memory, int blockSize, int numSets, int associativity, int blockOffsetBits, int setIndexBits) {
        int setIndex = (address >> blockOffsetBits) & ((1 << setIndexBits) - 1);
        int tag = address >> (blockOffsetBits + setIndexBits);
        boolean foundCache = false;
        for (int i = 0; i < associativity; i++) {
            CacheBlock block = cache[setIndex][i];
            if (block.valid && block.tag == tag) {
                System.out.print("store 0x" + Integer.toHexString(address));
                System.out.print(" hit");

                // Store in cache
                for (int j = 0; j < accessSize; j++) {
                    block.data[(address & (blockSize - 1)) + j] = data[j];
                }
                block.dirty = true;
                System.out.println();
                lruChange(cache, setIndex, i, associativity);
                foundCache = true;
                break;
            }
        }
    
        // Cache miss
        if (!foundCache) {
            boolean replacementPerformed = false;
            
            // Find an empty block or replace using LRU
            for (int i = 0; i < associativity; i++) {
                CacheBlock block = cache[setIndex][i];
                if (!block.valid) {
                    block.valid = true;
                    block.dirty = true;
                    block.tag = tag;

                    // Load from memory and then store it in cache
                    for (int j = 0; j < blockSize; j++) {
                        block.data[j] = memory[address - (address & (blockSize - 1)) + j];
                    }
                    for (int j = 0; j < accessSize; j++) {
                        block.data[(address & (blockSize - 1)) + j] = data[j];
                    }

                    // Update the LRU and then set flag to indicate replacement was performed
                    lruChange(cache, setIndex, i, associativity);
                    replacementPerformed = true;
                    break;
                }
            }
    
            if (!replacementPerformed) {
                int lruIndex = lruSearcher(cache, setIndex, associativity);
                CacheBlock lruBlock = cache[setIndex][lruIndex];
                // Write back to memory if dirty
                if (lruBlock.dirty) {
                    int removeAddress = (lruBlock.tag * (1 << (blockOffsetBits + setIndexBits))) + (setIndex * (1 << blockOffsetBits));
                    System.out.println("replacement 0x" + Integer.toHexString(removeAddress) + " dirty");
                    for (int j = 0; j < blockSize; j++) {
                        memory[removeAddress + j] = lruBlock.data[j];
                    }
                // Block is clean
                } else {
                    int removeAddress = (lruBlock.tag * (1 << (blockOffsetBits + setIndexBits))) + (setIndex * (1 << blockOffsetBits));
                    System.out.println("replacement 0x" + Integer.toHexString(removeAddress) + " clean");
                }
                
                // Load new block from memory and store it in the cache
                lruBlock.valid = true;
                lruBlock.dirty = true;
                lruBlock.tag = tag;
                for (int j = 0; j < blockSize; j++) {
                    lruBlock.data[j] = memory[address - (address & (blockSize - 1)) + j];
                }
                for (int j = 0; j < accessSize; j++) {
                    lruBlock.data[(address & (blockSize - 1)) + j] = data[j];
                }
                lruChange(cache, setIndex, lruIndex, associativity);
            }
            
            // print store line after storing to cache
            System.out.print("store 0x" + Integer.toHexString(address) + " miss ");
            System.out.println();
        }
    }

    public static void loadWord(int address, int accessSize, CacheBlock[][] cache, String[] memory, int blockSize, int numSets, int associativity, int blockOffsetBits, int setIndexBits) {
        int setIndex = (address >> blockOffsetBits) & ((1 << setIndexBits) - 1);
        int tag = address >> (blockOffsetBits + setIndexBits);
        boolean foundCache = false;
        for (int i = 0; i < associativity; i++) {
            CacheBlock block = cache[setIndex][i];
            if (block.valid && block.tag == tag) {
                System.out.print("load 0x" + Integer.toHexString(address));
                System.out.print(" hit ");

                // print the loaded value
                for (int j = 0; j < accessSize; j++) {
                    System.out.print(block.data[(address & (blockSize - 1)) + j]);
                }
                System.out.println();
                
                // Update the LRU
                lruChange(cache, setIndex, i, associativity);
                foundCache = true;
                break;
            }
        }
    
        if (!foundCache) {
            boolean replacementPerformed = false;
            // Find an empty block or replace using LRU
            for (int i = 0; i < associativity; i++) {
                CacheBlock block = cache[setIndex][i];
                if (!block.valid) {
                    block.valid = true;
                    block.dirty = false;
                    block.tag = tag;

                    // Load from memory
                    for (int j = 0; j < blockSize; j++) {
                        block.data[j] = memory[address - (address & (blockSize - 1)) + j];
                    }

                    // Update LRU and set a flag
                    lruChange(cache, setIndex, i, associativity);
                    replacementPerformed = true;
                    break;
                }
            }
    
            if (!replacementPerformed) {
                int lruIndex = lruSearcher(cache, setIndex, associativity);
                CacheBlock lruBlock = cache[setIndex][lruIndex];
                if (lruBlock.dirty) {

                    // Write back to memory if dirty
                    int removeAddress = (lruBlock.tag * (1 << (blockOffsetBits + setIndexBits))) + (setIndex * (1 << blockOffsetBits));
                    System.out.println("replacement 0x" + Integer.toHexString(removeAddress) + " dirty");
                    for (int j = 0; j < blockSize; j++) {
                        memory[removeAddress + j] = lruBlock.data[j];
                    }
                } else {

                    // Block is clean
                    int removeAddress = (lruBlock.tag * (1 << (blockOffsetBits + setIndexBits))) + (setIndex * (1 << blockOffsetBits));
                    System.out.println("replacement 0x" + Integer.toHexString(removeAddress) + " clean");
                }

                // Load new block from memory
                lruBlock.valid = true;
                lruBlock.dirty = false;
                lruBlock.tag = tag;
                for (int j = 0; j < blockSize; j++) {
                    lruBlock.data[j] = memory[address - (address & (blockSize - 1)) + j];
                }
                lruChange(cache, setIndex, lruIndex, associativity);
            }

            // Print load line after loading from memory
            System.out.print("load 0x" + Integer.toHexString(address) + " miss ");
            for (int j = 0; j < accessSize; j++) {
                System.out.print("00");
            }
            System.out.println();
        }
    }

    public static void main(String[] args) {
        if (args.length != 4) {
            System.exit(0);
        }

        // Get the inputs
        String traceFile = args[0];
        int cacheSizeKB = Integer.parseInt(args[1]);
        int associativity = Integer.parseInt(args[2]);
        int blockSize = Integer.parseInt(args[3]);

        // Calculate cache parameters to do the operations
        int blockOffsetBits = log2(blockSize);
        int cacheSize = cacheSizeKB * 1024; 
        int numberOfSets = (cacheSize / blockSize) / associativity;
        int setIndexBits = log2(numberOfSets);

        // Initialize cache
        CacheBlock[][] cache = new CacheBlock[numberOfSets][associativity];
        for (int i = 0; i < numberOfSets; i++) {
            for (int j = 0; j < associativity; j++) {
                cache[i][j] = new CacheBlock(blockSize);
            }
        }

        // initialize the memory array to 2^24 (16MB memory) and fill it up with zeros
        String[] memory = new String[16777216];
        Arrays.fill(memory, "00"); 

        // read the trace file
        try (BufferedReader br = new BufferedReader(new FileReader(traceFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split(" ");
                String operation = parts[0];
                int address = Integer.parseInt(parts[1].substring(2), 16);
                int accessSize = Integer.parseInt(parts[2]);
                String[] data = null;

                // get the value that is being written if it is store
                if (parts.length > 3 && operation.equals("store")) {
                    String hexData = parts[3];
                    int dataLength = hexData.length();
                    int dataSize = dataLength / 2;
                    data = new String[dataSize];
                    for (int i = 0; i < dataSize; i++) {
                        int startIndex = i * 2;
                        data[i] = hexData.substring(startIndex, startIndex + 2);
                    }
                }

                // decide on the operation (store or load)
                if (operation.equals("load")) {
                    loadWord(address, accessSize, cache, memory, blockSize, numberOfSets, associativity, blockOffsetBits, setIndexBits);
                } else if (operation.equals("store")) {
                    storeWord(address, accessSize, data, cache, memory, blockSize, numberOfSets, associativity, blockOffsetBits, setIndexBits);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        System.exit(0); 
    }
}