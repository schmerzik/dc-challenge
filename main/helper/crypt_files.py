import argparse
import logging
from simplecrypt import encrypt, decrypt


def run(argv=None):
    parser = argparse.ArgumentParser()

    # --file
    parser.add_argument(
        '--file',
        dest='file',
        required=True)

    # --type
    parser.add_argument('--type',
        dest='type',
        required=True)

    # --password
    parser.add_argument('--password',
        dest='password',
        required=True)

    my_args, other_args = parser.parse_known_args(argv)

    # CHECK PARAMETERS
    enc = False
    dec = False
    if my_args.type == 'encrypt':
        enc = True
    elif my_args.type == 'decrypt':
        dec = True
    else:
        raise Exception('Must specify encrypt or decrypt as type')
    if my_args.file is None or my_args.file == '':
        raise Exception('Invalid file')

    # READ (enc/dec) FILE & WRITE (dec/enc) FILE
    if enc:
        rFileName = my_args.file
        wFileName = my_args.file + "_encrypted"
    if dec:
        rFileName = my_args.file + "_encrypted"
        wFileName = my_args.file
    newFileContent = None

    try:
        # READ
        if enc:
            file = open(rFileName,mode='r')
        if dec:
            file = open(rFileName,mode='rb')
        fileContent = file.read()
        file.close()
        if fileContent is None:
            raise Exception('Invalid file')

        # CONVERT
        if enc:
            newFileContent = encrypt(my_args.password, fileContent)
        if dec:
            newFileContent = decrypt(my_args.password, fileContent).decode('utf-8')

        # WRITE
        if enc:
            file = open(wFileName,mode='wb')
        if dec:
            file = open(wFileName,mode='w')
        file.write(newFileContent)
        file.close()
    except Exception as e:
        print('Issue reading/encrypting/decrypting/writing file: {}'.format(e))
        raise e

    if enc:
        print('Encryption complete')
    if dec:
        print('Decryption complete')


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run()
