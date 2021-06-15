'''
查找后代节点
'''
def find_successors(p_course, course_list):
    res_list = [(*x, 0) for x in course_list if x[0] == p_course]
    lev = 1
    while True:
        i = 0
        t_list = res_list[:]
        id_list = [x[0] for x in t_list]  # 已存在的课程id
        for t in t_list:
            for c in course_list:
                if c[1] == t[0] and c[0] not in id_list:
                    res_list.append((*c, lev))
                    i += 1
        lev += 1
        if i == 0:
            break
    return res_list
    

course_list = [('BIO-301', 'BIO-101'), 
    ('BIO-399', 'BIO-101'), 
    ('CS-190', 'CS-101'), 
    ('CS-315', 'CS-101'),
    ('CS-319', 'CS-101'), 
    ('CS-347', 'CS-101'), 
    ('EE-181', 'PHY-101'), 
    ('CS-101', 'CS-10'),
    ('CS-10', 'CS-1')]

p_course = 'CS-10'

res = find_successors(p_course, course_list=course_list)
print(res)