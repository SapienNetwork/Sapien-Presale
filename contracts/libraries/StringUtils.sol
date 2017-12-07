pragma solidity ^0.4.18;

library StringUtils {

    /// @dev Does a byte-by-byte lexicographical comparison of two strings.
    /// @return a negative number if `_a` is smaller, zero if they are equal
    /// and a positive numbe if `_b` is smaller

    function compare(string _a, string _b) returns (int) {

        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);

        uint minLength = a.length;

        if (b.length < minLength) {

            minLength = b.length;

        }
	      
        for (uint i = 0; i < minLength; i++) {

            if (a[i] < b[i]) {

                return -1;

            } else if (a[i] > b[i]) {

                return 1;

            } 

        }

        if (a.length < b.length) {

            return -1;

        } else if (a.length > b.length) {

            return 1;

        } else {

            return 0;

        }   

    }

    /// @dev Compares two strings and returns true iff they are equal.

    function equal(string _a, string _b) returns (bool) {

        return compare(_a, _b) == 0;

    }

    /// @dev Finds the index of the first occurrence of _needle in _haystack

    function indexOf(string _haystack, string _needle) returns (int) {

    	bytes memory h = bytes(_haystack);
    	bytes memory n = bytes(_needle);

    	if(h.length < 1 || n.length < 1 || (n.length > h.length)) {

            return -1;

        } else if (h.length > (2**128 - 1)) {

            return -1;

        } else {
    	
	        uint subindex = 0;

    	    for (uint i = 0; i < h.length; i ++) {

    		          if (h[i] == n[0]) {

    		          subindex = 1;

    		          while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex]) {

    			          subindex++;

    		          }

    		          if (subindex == n.length) {

                        return int(i);

                     }    

    	           }
              }

            return -1;

        }	

    }
  
}