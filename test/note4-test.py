import argparse



def main():
    parser = argparse.ArgumentParser(description="批量处理文件")

    # 位置参数: 输入文件(支持多个)
    parser.add_argument('input_files', nargs='+', help='输入文件路径')

    # 可选参数：输出目录
    parser.add_argument('-o', '--output', default='./output', help='输出目录(默认:./output)')
    
    # 可选参数：处理模式
    parser.add_argument('-m', '--mode', choices=['upper', 'lower', 'capitalize'],  default='upper', help='文件转换模式')

    # 标志参数：是否覆盖
    parser.add_argument('-f', '--force', action='store_true', help='强制覆盖已存在的文件')

    # 互斥参数组(只能选一个)
    group = parser.add_mutually_exclusive_group()
    group.add_argument('-v', '--verbose', action='store_true', help='详细输出')
    group.add_argument('-q', '--quiet', action='store_true', help='静默模式')

    args = parser.parse_args()

    # 业务逻辑
    if args.verbose:
        print(f'处理模式：{args.mode}')
        print(f'输入文件：{args.input_files}')
        print(f'输出目录：{args.output}')
        print(f'强制覆盖：{args.force}')
        print(f'啰嗦模式：{args.verbose}')
        print(f'静默模式：{args.quiet}')

    # 处理逻辑
    print('处理完成!')


if __name__ == '__main__':
    main()


#test
#python argparse_test.py file1.txt file2.txt -o ./result -m lower -v











